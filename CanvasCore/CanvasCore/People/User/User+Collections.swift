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



// ---------------------------------------------
// MARK: - Calendar Events collection for current user
// ---------------------------------------------
extension User {
    public static func collectionOfObservedUsers(_ session: Session) throws -> FetchedCollection<User> {
        let context = try session.observeesManagedObjectContext()

        return try FetchedCollection<User>(frc:
            context.fetchedResults(nil, sortDescriptors: ["sortableName".ascending])
        )
    }

    public static func observeesSyncProducer(_ session: Session) throws -> User.ModelPageSignalProducer {
        let remote = try User.getObserveeUsers(session)
        return User.syncSignalProducer(inContext: try session.observeesManagedObjectContext(), fetchRemote: remote)
    }

    public static func observeesRefresher(_ session: Session) throws -> Refresher {
        let sync = try User.observeesSyncProducer(session)
        let key = cacheKey(try session.observeesManagedObjectContext())
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}
