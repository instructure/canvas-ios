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
