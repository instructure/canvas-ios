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

import CoreData

extension UserEnrollment {
    public static func refresher(enrolledInCourseWithID courseID: String, for session: Session) throws -> Refresher {
        let moc = try session.peepsManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "courseID", courseID)
        let refreshProducer = UserEnrollment.syncSignalProducer(predicate, inContext: moc, fetchRemote: try UserEnrollment.getUsers(enrolledInCourseWithID: courseID, session: session))
        
        let key = cacheKey(moc, [courseID])
        return SignalProducerRefresher(refreshSignalProducer: refreshProducer, scope: session.refreshScope, cacheKey: key)
    }
}
