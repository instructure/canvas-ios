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



extension Group {
    
    public static func refresher(_ session: Session) throws -> Refresher {
        let remote = try getAllGroups(session)
        let context = try session.enrollmentManagedObjectContext()
        let sync = syncSignalProducer(inContext: context, fetchRemote: remote)
            .map { _ in }
        let colors = Enrollment.syncFavoriteColors(session, inContext: context)
        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync.concat(colors), scope: session.refreshScope, cacheKey: key)
    }
    
    public static func favoritesCollection(_ session: Session) throws -> FetchedCollection<Group> {
        let favorites = NSPredicate(format: "%K == YES", "isFavorite")
        let context = try session.enrollmentManagedObjectContext()
        return try FetchedCollection(frc:
            context.fetchedResults(favorites, sortDescriptors: ["name".ascending, "id".ascending])
        )
    }
}
