//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


import ReactiveSwift


import Result
import CoreData

extension ModuleItem {
    public static func beginObservingProgress(_ session: Session) {
        guard let context = try? session.soEdventurousManagedObjectContext() else { return }
        session
            .progressDispatcher
            .onProgress
            .observe(on: ManagedObjectContextScheduler(context: context))
            .observeValues { progress in
                ModuleItem.apply(session, progress: progress)
            }
    }

    static func apply(_ session: Session, progress: Progress) {
        let moduleItems: SignalProducer<SignalProducer<Void, NSError>, NSError> = attemptProducer {
            let context = try session.soEdventurousManagedObjectContext()

            let moduleItems: [ModuleItem] = try context.findAll(matchingPredicate: ModuleItem.predicate(progress))
            let updates: [SignalProducer<Void, NSError>] = try moduleItems.map { moduleItem in

                let edit: SignalProducer<Void, NSError>

                switch progress.kind {
                case .viewed:
                    edit = try moduleItem.markRead(session: session)
                case .markedDone:
                    edit = try moduleItem.markDone(session: session)
                default: edit = .empty
                }

                let invalidateCache = attemptProducer {
                    try ModuleItem.invalidateCache(session, courseID: moduleItem.courseID, moduleID: moduleItem.moduleID)
                }

                let postModuleItemProgress = blockProducer {
                    let progress = Progress(kind: progress.kind, contextID: progress.contextID, itemType: .moduleItem, itemID: moduleItem.id)
                    session.progressDispatcher.dispatch(progress)
                }

                return edit
                    .concat(invalidateCache)
                    .concat(postModuleItemProgress.promoteErrors(NSError.self))
            }

            return SignalProducer<SignalProducer<Void, NSError>, NSError>(updates).flatten(.merge)
        }

        moduleItems
            .flatten(.merge)
            .start()
    }

    fileprivate static func invalidateCache(_ session: Session, courseID: String, moduleID: String) throws {
        let context = try session.soEdventurousManagedObjectContext()
        session.refreshScope.invalidateCache(Module.collectionCacheKey(context: context, courseID: courseID))
        session.refreshScope.invalidateCache(Module.detailsCacheKey(context: context, courseID: courseID, moduleID: moduleID))
        let dependentModules: [Module] = try context.findAll(matchingPredicate: Module.predicate(withPrerequisite: moduleID))
        let dependentModuleIDs = Set(dependentModules.map { $0.id })
        dependentModuleIDs.forEach {
            session.refreshScope.invalidateCache(Module.detailsCacheKey(context: context, courseID: courseID, moduleID: $0))
        }
    }

    public func postProgress(_ session: Session, kind: Progress.Kind) {
        guard let itemType = progressItemType, let itemID = progressItemID else {
            return
        }

        let contextID = ContextID(id: courseID, context: .course)
        let progress = Progress(kind: kind, contextID: contextID, itemType: itemType, itemID: itemID)

        session.progressDispatcher.dispatch(progress)
    }

    static func predicate(_ progress: Progress) -> NSPredicate {
        let contentID = NSPredicate(format: "%K == %@", "contentID", progress.itemID)
        let pageURL = NSPredicate(format: "%K == %@", "pageURL", progress.itemID)
        let externalURL = NSPredicate(format: "%K == %@", "externalURL", progress.itemID)
        let url = NSPredicate(format: "%K == %@", "url", progress.itemID)
        let type = contentType(progress).flatMap { NSPredicate(format: "%K == %@", "contentType", $0.rawValue) }
        let course = progress.contextID.context == .course ? NSPredicate(format: "%K == %@", "courseID", progress.contextID.id) : NSPredicate(value: false)
        let requirement = NSPredicate(format: "%K == %@", "completionRequirement", completionRequirement(progress).rawValue)
        let incomplete = NSPredicate(format: "%K == %@", "completed", NSNumber(value: false as Bool))
        let unlocked = NSPredicate(format: "%K == false", "lockedForUser", NSNumber(value: false as Bool))

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [type, course, requirement, incomplete, unlocked].flatMap { $0 })

        switch progress.itemType {
        case .legacyModuleProgressShim:
            // The legacy module item progress (CBIPostModuleItemProgressUpdate) does not
            // include the course id or the item type so we find them the best we can
            // using only the `itemID` and the `completionRequirement`.
            let id = NSCompoundPredicate(orPredicateWithSubpredicates: [contentID, pageURL, externalURL, url])
            return NSCompoundPredicate(andPredicateWithSubpredicates: [id, requirement, incomplete, unlocked])
        case .assignment, .file, .quiz, .discussion:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [contentID, predicate])
        case .page:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [pageURL, predicate])
        case .url, .externalTool:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [externalURL, predicate])
        case .moduleItem:
            return NSPredicate(value: false)
        }
    }


    // MARK: - ModuleItem <-> Progress

    var progressItemType: Progress.ItemType? {
        switch contentType {
        case .file: return .file
        case .page: return .page
        case .discussion: return .discussion
        case .assignment: return .assignment
        case .quiz: return .quiz
        case .externalURL: return .url
        case .externalTool: return .externalTool
        case .subHeader, .masteryPaths: return nil
        }
    }

    var progressItemID: String? {
        guard let content = content else {
            return nil
        }
        switch content {
        case .file(let fileID):
            return fileID
        case .page(let pageURL):
            return pageURL
        case .discussion(let discussionID):
            return discussionID
        case .assignment(let assignmentID):
            return assignmentID
        case .quiz(let quizID):
            return quizID
        case .subHeader, .masteryPaths:
            return nil
        case .externalURL(let url):
            return url.absoluteString
        case .externalTool(_, let toolURL):
            return toolURL.absoluteString
        }
    }

    public static func contentType(_ progress: Progress) -> ContentType? {
        switch progress.itemType {
        case .file: return .file
        case .page: return .page
        case .discussion: return .discussion
        case .assignment: return .assignment
        case .quiz: return .quiz
        case .url: return .externalURL
        case .externalTool: return .externalTool
        case .legacyModuleProgressShim, .moduleItem: return nil
        }
    }

    public static func completionRequirement(_ progress: Progress) -> CompletionRequirement {
        let completionRequirement: CompletionRequirement
        switch progress.kind {
        case .viewed: completionRequirement = .mustView
        case .contributed: completionRequirement = .mustContribute
        case .markedDone: completionRequirement = .markDone
        case .minimumScore: completionRequirement = .minScore
        case .submitted: completionRequirement = .mustSubmit
        }
        return completionRequirement
    }
}
