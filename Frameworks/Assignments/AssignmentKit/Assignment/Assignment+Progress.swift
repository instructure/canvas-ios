
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
