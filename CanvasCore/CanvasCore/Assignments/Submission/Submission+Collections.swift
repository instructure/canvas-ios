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

import Foundation
import ReactiveSwift
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
