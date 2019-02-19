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
