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
