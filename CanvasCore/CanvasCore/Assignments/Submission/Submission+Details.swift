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
    
    

import UIKit


import CoreData
import ReactiveSwift


extension Submission {
    
    public static func detailsCacheKey(_ context: NSManagedObjectContext, courseID: String, assignmentID: String, userID: String) -> String {
        return cacheKey(context, [courseID, assignmentID, userID])
    }
    
    public static func predicate(_ courseID: String, assignmentID: String, userID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@ && %K == %@", "courseID", courseID, "assignmentID", assignmentID, "userID", userID)
    }
    
    public static func refreshSignalProducer(_ session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<[Submission], NSError> {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try Submission.getSubmission(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let pred = predicate(courseID, assignmentID: assignmentID, userID: session.user.id)
        return Submission.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
    }
    
    public static func observer(_ session: Session, courseID: String, assignmentID: String) throws -> ManagedObjectObserver<Submission> {
        let pred = predicate(courseID, assignmentID: assignmentID, userID: session.user.id)
        let context = try session.assignmentsManagedObjectContext()
        return try ManagedObjectObserver<Submission>(predicate: pred, inContext: context)
    }

    public static func create(_ newSubmission: NewSubmission, session: Session, courseID: String, assignmentID: String, comment: String?) throws -> SignalProducer<Submission, NSError> {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try self.post(newSubmission, session: session, courseID: courseID, assignmentID: assignmentID, comment: comment)
        return remote
            .map { [$0] }
            .flatMap(.concat) { Submission.upsert(inContext: context, jsonArray: $0) }
            .uncollect()
    }
}
