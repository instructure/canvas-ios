//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation

import ReactiveSwift
import Result

import CoreData

extension Assignment {
    
    // MARK: dispatching progress
    public func postProgress(_ session: Session, kind: Progress.Kind) {
        let progress = Progress(kind: kind, contextID: .course(withID: courseID), itemType: .assignment, itemID: id)
        session
            .progressDispatcher
            .dispatch(progress)
    }

    // MARK: observing progress updates
    static func invalidateCaches(_ progress: Progress, scope: RefreshScope, context: NSManagedObjectContext) {
        
        let collection = Assignment.collectionCacheKey(context, courseID: progress.contextID.id)
        scope.invalidateCache(collection)
        
        func invalidateDetail(_ course: ContextID, assignmentID: String) {
            let detail = Assignment.detailsCacheKey(context, courseID: progress.contextID.id, id: progress.itemID)
            scope.invalidateCache(detail)
        }
        
        switch (progress.kind, progress.itemType) {
            
        case (.submitted, .assignment):
            invalidateDetail(progress.contextID, assignmentID: progress.itemID)
            
        case (.contributed, .discussion):
            if let assignment: Assignment = (try? context.findOne(withValue: progress.itemID, forKey: "discussionTopicID") as? Assignment).flatMap({ $0 }) {
                invalidateDetail(progress.contextID, assignmentID: assignment.id)
            }
            
        case (.submitted, .quiz):
            if let assignment: Assignment = (try? context.findOne(withValue: progress.itemID, forKey: "quizID") as? Assignment).flatMap({ $0 }) {
                invalidateDetail(progress.contextID, assignmentID: assignment.id)
            }
            
        case (.submitted, .externalTool):
            if let assignment: Assignment = (try? context.findOne(withValue: progress.itemID, forKey: "url") as? Assignment).flatMap({$0}) {
                invalidateDetail(progress.contextID, assignmentID: assignment.id)
            }
            
        default: break // not progress we care about
        }
    }
    
    static func beginObservingProgress(_ session: Session) {
        guard let context = try? session.assignmentsManagedObjectContext() else { ❨╯°□°❩╯⌢"you couldn't even get the context?!" }
        let scope = session.refreshScope
        
        let progress = session
            .progressDispatcher
            .onProgress
            .observe(on: ManagedObjectContextScheduler(context: context))

        progress.observeValues { invalidateCaches($0, scope: scope, context: context) }
    }
}
