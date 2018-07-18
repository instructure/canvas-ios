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

import CoreData

extension UserEnrollment {
    public static func refresher(enrolledInCourseWithID courseID: String, for session: Session) throws -> Refresher {
        let moc = try session.peepsManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "courseID", courseID)
        let refreshProducer = UserEnrollment.syncSignalProducer(predicate, inContext: moc, fetchRemote: try UserEnrollment.getUsers(enrolledInCourseWithID: courseID, session: session))
        
        let key = cacheKey(moc, [courseID])
        return SignalProducerRefresher(refreshSignalProducer: refreshProducer, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func collectionByRole(enrolledInCourseWithID courseID: String, as roles: [UserEnrollmentRole] = [], for session: Session) throws -> FetchedCollection<UserEnrollment> {
        
        let predicate: NSPredicate
        if !roles.isEmpty {
            predicate = NSPredicate(format: "%K == %@ && %@ CONTAINS %K ", "courseID", courseID, roles.map { $0.rawValue }, "role")
        } else {
            predicate = NSPredicate(format: "%K == %@", "courseID", courseID)
        }
        
        let context = try session.peepsManagedObjectContext()
        let frc: NSFetchedResultsController<UserEnrollment> = context.fetchedResults(predicate, sortDescriptors: ["roleOrder".ascending, "user.sortableName".ascending], sectionNameKeypath: "role", propertiesToFetch: ["user"])
        return try FetchedCollection(frc: frc) { role in
            return role
                .flatMap { UserEnrollmentRole(rawValue: $0) }
                .map { $0.title }
        }
    }
}
