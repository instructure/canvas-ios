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
