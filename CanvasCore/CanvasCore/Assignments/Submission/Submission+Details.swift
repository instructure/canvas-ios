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
