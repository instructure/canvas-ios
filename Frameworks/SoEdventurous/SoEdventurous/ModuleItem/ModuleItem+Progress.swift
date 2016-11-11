//
//  ModuleItem+Progress.swift
//  SoEdventurous
//
//  Created by Nathan Armstrong on 10/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoProgressive
import ReactiveCocoa
import TooLegit
import SoPersistent
import Result
import CoreData
import SoProgressive

extension ModuleItem {
    public static func beginObservingProgress(session: Session) {
        guard let context = try? session.soEdventurousManagedObjectContext() else { return }
        session
            .progressDispatcher
            .onProgress
            .observeOn(ManagedObjectContextScheduler(context: context))
            .observeNext { progress in
                ModuleItem.apply(session, progress: progress)
            }
    }

    static func apply(session: Session, progress: Progress) {
        let moduleItems: SignalProducer<SignalProducer<Void, NSError>, NSError> = attemptProducer {
            let context = try session.soEdventurousManagedObjectContext()

            let moduleItems: [ModuleItem] = try context.findAll(matchingPredicate: ModuleItem.predicate(progress))
            let updates: [SignalProducer<Void, NSError>] = try moduleItems.map { moduleItem in

                let edit: SignalProducer<Void, NSError>

                switch progress.kind {
                case .Viewed:
                    edit = try moduleItem.markRead(session)
                case .MarkedDone:
                    edit = try moduleItem.markDone(session)
                default: edit = .empty
                }

                let invalidateCache = attemptProducer {
                    try ModuleItem.invalidateCache(session, courseID: moduleItem.courseID)
                }

                let postModuleItemProgress = blockProducer {
                    let progress = Progress(kind: progress.kind, contextID: progress.contextID, itemType: .ModuleItem, itemID: moduleItem.id)
                    session.progressDispatcher.dispatch(progress)
                }

                return edit
                    .concat(invalidateCache)
                    .concat(postModuleItemProgress.promoteErrors(NSError))
            }

            return SignalProducer<SignalProducer<Void, NSError>, NSError>(values: updates).flatten(.Merge)
        }

        moduleItems
            .flatten(.Merge)
            .start()
    }

    private static func invalidateCache(session: Session, courseID: String) throws {
        let context = try session.soEdventurousManagedObjectContext()
        session.refreshScope.invalidateCache(Module.collectionCacheKey(context, courseID: courseID))
    }

    public func postProgress(session: Session, kind: Progress.Kind) {
        guard let itemType = progressItemType, itemID = progressItemID else {
            return
        }

        let contextID = ContextID(id: courseID, context: .Course)
        let progress = Progress(kind: kind, contextID: contextID, itemType: itemType, itemID: itemID)

        session.progressDispatcher.dispatch(progress)
    }

    static func predicate(progress: Progress) -> NSPredicate {
        let contentID = NSPredicate(format: "%K == %@", "contentID", progress.itemID)
        let pageURL = NSPredicate(format: "%K == %@", "pageURL", progress.itemID)
        let externalURL = NSPredicate(format: "%K == %@", "externalURL", progress.itemID)
        let type = contentType(progress).flatMap { NSPredicate(format: "%K == %@", "contentType", $0.rawValue) }
        let course = progress.contextID.context == .Course ? NSPredicate(format: "%K == %@", "courseID", progress.contextID.id) : NSPredicate(value: false)
        let requirement = NSPredicate(format: "%K == %@", "completionRequirement", completionRequirement(progress).rawValue)
        let incomplete = NSPredicate(format: "%K == %@", "completed", NSNumber(bool: false))
        let unlocked = NSPredicate(format: "%K == false", "lockedForUser", NSNumber(bool: false))

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [type, course, requirement, incomplete, unlocked].flatMap { $0 })

        switch progress.itemType {
        case .LegacyModuleProgressShim:
            // The legacy module item progress (CBIPostModuleItemProgressUpdate) does not
            // include the course id or the item type so we find them the best we can
            // using only the `itemID` and the `completionRequirement`.
            let id = NSCompoundPredicate(orPredicateWithSubpredicates: [contentID, pageURL, externalURL])
            return NSCompoundPredicate(andPredicateWithSubpredicates: [id, requirement, incomplete, unlocked])
        case .Assignment, .File, .Quiz, .Discussion:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [contentID, predicate])
        case .Page:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [pageURL, predicate])
        case .URL, .ExternalTool:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [externalURL, predicate])
        case .ModuleItem:
            return NSPredicate(value: false)
        }
    }


    // MARK: - ModuleItem <-> Progress

    var progressItemType: Progress.ItemType? {
        switch contentType {
        case .file: return .File
        case .page: return .Page
        case .discussion: return .Discussion
        case .assignment: return .Assignment
        case .quiz: return .Quiz
        case .externalURL: return .URL
        case .externalTool: return .ExternalTool
        case .subHeader, .masteryPaths: return nil
        }
    }

    var progressItemID: String? {
        guard let content = content else {
            return nil
        }
        switch content {
        case .File(let fileID):
            return fileID
        case .Page(let pageURL):
            return pageURL.absoluteString
        case .Discussion(let discussionID):
            return discussionID
        case .Assignment(let assignmentID):
            return assignmentID
        case .Quiz(let quizID):
            return quizID
        case .SubHeader, .MasteryPaths:
            return nil
        case .ExternalURL(let url):
            return url.absoluteString
        case .ExternalTool(_, let toolURL):
            return toolURL.absoluteString
        }
    }

    public static func contentType(progress: Progress) -> ContentType? {
        switch progress.itemType {
        case .File: return .file
        case .Page: return .page
        case .Discussion: return .discussion
        case .Assignment: return .assignment
        case .Quiz: return .quiz
        case .URL: return .externalURL
        case .ExternalTool: return .externalTool
        case .LegacyModuleProgressShim, .ModuleItem: return nil
        }
    }

    public static func completionRequirement(progress: Progress) -> CompletionRequirement {
        let completionRequirement: CompletionRequirement
        switch progress.kind {
        case .Viewed: completionRequirement = .MustView
        case .Contributed: completionRequirement = .MustContribute
        case .MarkedDone: completionRequirement = .MarkDone
        case .MinimumScore: completionRequirement = .MinScore
        case .Submitted: completionRequirement = .MustSubmit
        }
        return completionRequirement
    }
}
