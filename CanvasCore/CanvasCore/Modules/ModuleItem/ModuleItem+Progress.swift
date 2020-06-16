//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import ReactiveSwift
import CoreData
import Core

extension ModuleItem {
    @objc public static func beginObservingProgress(_ session: Session) {
        guard let context = try? session.soEdventurousManagedObjectContext() else { return }
        session
            .progressDispatcher
            .onProgress
            .observe(on: ManagedObjectContextScheduler(context: context))
            .observeValues { progress in
                ModuleItem.apply(session, progress: progress)
            }
        NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) { [weak session] notification in
            guard
                let session = session,
                let userInfo = notification.userInfo,
                let requirement = userInfo["requirement"] as? ModuleItemCompletionRequirement,
                let item = userInfo["moduleItem"] as? ModuleItemType,
                let courseID = userInfo["courseID"] as? String
            else {
                return
            }
            let contextID = Context(.course, id: courseID)

            let kind: Progress.Kind
            switch requirement {
            case .view:
                kind = .viewed
            case .submit:
                kind = .submitted
            case .contribute:
                kind = .contributed
            }

            let progress: Progress
            switch item {
            case let .assignment(id):
                progress = Progress(kind: kind, contextID: contextID, itemType: .assignment, itemID: id)
            case let .discussion(id):
                progress = Progress(kind: kind, contextID: contextID, itemType: .discussion, itemID: id)
            case let .externalTool(id, _):
                progress = Progress(kind: kind, contextID: contextID, itemType: .externalTool, itemID: id)
            case let .externalURL(url):
                progress = Progress(kind: kind, contextID: contextID, itemType: .url, itemID: url.absoluteString)
            case let .file(id):
                progress = Progress(kind: kind, contextID: contextID, itemType: .file, itemID: id)
            case let .page(url):
                progress = Progress(kind: kind, contextID: contextID, itemType: .page, itemID: url)
            case let .quiz(id):
                progress = Progress(kind: kind, contextID: contextID, itemType: .quiz, itemID: id)
            case .subHeader:
                return
            }
            apply(session, progress: progress)
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
                case .contributed:
                    edit = try moduleItem.markContributed(session: session)
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
                    .concat(postModuleItemProgress.promoteError(NSError.self))
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
        let dependentModuleIDs = Set(dependentModules.map { $0.id } + [moduleID])
        dependentModuleIDs.forEach {
            session.refreshScope.invalidateCache(Module.detailsCacheKey(context: context, courseID: courseID, moduleID: $0))
        }
    }

    public func postProgress(_ session: Session, kind: Progress.Kind) {
        guard let itemType = progressItemType, let itemID = progressItemID else {
            return
        }

        let contextID = Context(.course, id: courseID)
        let progress = Progress(kind: kind, contextID: contextID, itemType: itemType, itemID: itemID)

        session.progressDispatcher.dispatch(progress)
    }

    static func predicate(_ progress: Progress) -> NSPredicate {
        let contentID = NSPredicate(format: "%K == %@", "contentID", progress.itemID)
        let pageURL = NSPredicate(format: "%K == %@", "pageURL", progress.itemID)
        let externalURL = NSPredicate(format: "%K == %@", "externalURL", progress.itemID)
        let url = NSPredicate(format: "%K == %@", "url", progress.itemID)
        let type = contentType(progress).flatMap { NSPredicate(format: "%K == %@", "contentType", $0.rawValue) }
        let course = progress.contextID.contextType == .course ? NSPredicate(format: "%K == %@", "courseID", progress.contextID.id) : NSPredicate(value: false)
        let requirement = NSPredicate(format: "%K == %@", "completionRequirement", completionRequirement(progress).rawValue)
        let incomplete = NSPredicate(format: "%K == %@", "completed", NSNumber(value: false as Bool))
        let unlocked = NSPredicate(format: "%K == false", "lockedForUser", NSNumber(value: false as Bool))

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [type, course, requirement, incomplete, unlocked].compactMap { $0 })

        switch progress.itemType {
        case .legacyModuleProgressShim:
            // The legacy module item progress (CBIPostModuleItemProgressUpdate) does not
            // include the course id or the item type so we find them the best we can
            // using only the `itemID` and the `completionRequirement`.
            let id = NSCompoundPredicate(orPredicateWithSubpredicates: [contentID, pageURL, externalURL, url])
            return NSCompoundPredicate(andPredicateWithSubpredicates: [id, requirement, incomplete, unlocked])
        case .assignment, .file, .quiz, .discussion, .externalTool:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [contentID, predicate])
        case .page:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [pageURL, predicate])
        case .url:
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

    @objc var progressItemID: String? {
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
