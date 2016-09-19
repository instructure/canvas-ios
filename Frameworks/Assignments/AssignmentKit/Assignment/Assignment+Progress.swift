//
//  Assignment+Progress.swift
//  Assignments
//
//  Created by Derrick Hathaway on 4/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import ReactiveCocoa
import Result
import SoLazy
import SoProgressive
import SoPersistent
import CoreData

extension Assignment {
    
    // MARK: dispatching progress
    public func postProgress(session: Session, kind: Progress.Kind) {
        let progress = Progress(kind: kind, contextID: ContextID(id: courseID, context: .Course), itemType: .Assignment, itemID: id)
        session
            .progressDispatcher
            .dispatch(progress)
    }

    // MARK: observing progress updates
    static func invalidateCaches(progress: Progress, scope: RefreshScope, context: NSManagedObjectContext) {
        
        let collection = Assignment.collectionCacheKey(context, courseID: progress.contextID.id)
        scope.invalidateCache(collection)
        
        func invalidateDetail(course: ContextID, assignmentID: String) {
            let detail = Assignment.detailsCacheKey(context, courseID: progress.contextID.id, id: progress.itemID)
            scope.invalidateCache(detail)
        }
        
        switch (progress.kind, progress.itemType) {
            
        case (.Submitted, .Assignment):
            invalidateDetail(progress.contextID, assignmentID: progress.itemID)
            
        case (.Contributed, .Discussion):
            if let assignment: Assignment = (try? context.findOne(withValue: progress.itemID, forKey: "discussionTopicID") as? Assignment).flatMap({ $0 }) {
                invalidateDetail(progress.contextID, assignmentID: assignment.id)
            }
            
        case (.Submitted, .Quiz):
            if let assignment: Assignment = (try? context.findOne(withValue: progress.itemID, forKey: "quizID") as? Assignment).flatMap({ $0 }) {
                invalidateDetail(progress.contextID, assignmentID: assignment.id)
            }
            
        case (.Submitted, .ExternalTool):
            if let assignment: Assignment = (try? context.findOne(withValue: progress.itemID, forKey: "url") as? Assignment).flatMap({$0}) {
                invalidateDetail(progress.contextID, assignmentID: assignment.id)
            }
            
        default: break // not progress we care about
        }
    }
    
    static func beginObservingProgress(session: Session) {
        guard let context = try? session.assignmentsManagedObjectContext() else { ❨╯°□°❩╯⌢"you couldn't even get the context?!" }
        let scope = session.refreshScope
        
        let progress = session
            .progressDispatcher
            .onProgress
            .observeOn(ManagedObjectContextScheduler(context: context))

        progress.observeNext { invalidateCaches($0, scope: scope, context: context) }
    }
}
