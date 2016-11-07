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

import TooLegit
import SoPersistent

extension UserEnrollment {
    public static func refresher(enrolledIn context: ContextID, for session: Session) throws -> Refresher {
        let moc = try session.peepsManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "contextID", context.canvasContextID)
        let refreshProducer = UserEnrollment.syncSignalProducer(predicate, inContext: moc, fetchRemote: try User.getUsers(context, session: session)) { enrollment, _ in
            enrollment.contextID = context
        }
        
        let key = cacheKey(moc, [context.canvasContextID])
        return SignalProducerRefresher(refreshSignalProducer: refreshProducer, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func collection(enrolledIn contextID: ContextID, as roles: UserEnrollmentRoles = [], for session: Session) throws -> FetchedCollection<UserEnrollment> {
        
        let predicate: NSPredicate
        if !roles.isEmpty {
            predicate = NSPredicate(format: "%K == %@ && (%K & %@) > 0", "contextID", contextID.canvasContextID, "roles", NSNumber(int: roles.rawValue))
        } else {
            predicate = NSPredicate(format: "%K == %@", "contextID", contextID.canvasContextID)
        }
        
        let frc = UserEnrollment.fetchedResults(predicate, sortDescriptors: ["user.sortableName".ascending], sectionNameKeypath: nil, propertiesToFetch: ["user"], inContext: try session.peepsManagedObjectContext())
        
        return try FetchedCollection(frc: frc)
    }
}
