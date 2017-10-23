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

import ReactiveSwift
import Result

import CoreData

extension Submission {
    public static func studentSubmissionsRefresher(_ session: Session, courseID: String, assignmentID: String) throws -> Refresher {
        let context = try session.assignmentsManagedObjectContext()
        
        let get = try Submission.getStudentSubmissions(session, courseID: courseID, assignmentID: assignmentID)
        let sync = Submission.syncSignalProducer(inContext: context, fetchRemote: get)
        
        let key = cacheKey(context, [courseID, assignmentID, "all_students"])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func studentSubmissionsCollection(_ session: Session, courseID: String, assignmentID: String) throws -> FetchedCollection<Submission> {
        let context = try session.assignmentsManagedObjectContext()
        
        let predicate = NSPredicate(format: "%K == %@", "assignmentID", assignmentID)
        let frc: NSFetchedResultsController<Submission> = context.fetchedResults(predicate, sortDescriptors: ["submittedAt".ascending, "id".ascending])
        
        return try FetchedCollection(frc: frc)
    }
}
