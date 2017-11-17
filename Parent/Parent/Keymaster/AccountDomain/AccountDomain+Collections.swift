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

import CanvasCore


// ---------------------------------------------
// MARK: - AccountDomains Collection
// ---------------------------------------------
extension AccountDomain {
    public static func predicate(_ searchTerm: String) -> NSPredicate? {
        return (searchTerm.characters.count > 0) ? NSPredicate(format: "%K CONTAINS[c] %@ OR %K CONTAINS[c] %@", "name", searchTerm, "domain", searchTerm) : nil
    }

    public static func collectionBySearchTerm(_ context: NSManagedObjectContext, searchTerm: String) throws -> FetchedCollection<AccountDomain> {
        return try FetchedCollection<AccountDomain>(frc:
            context.fetchedResults(predicate(searchTerm), sortDescriptors: ["name".ascending])
        )
    }

    public static func collection(_ context: NSManagedObjectContext) throws -> FetchedCollection<AccountDomain> {
        return try FetchedCollection<AccountDomain>(frc:
            context.fetchedResults(nil, sortDescriptors: ["name".ascending])
        )
    }

    public static func refresher(_ context: NSManagedObjectContext) throws -> Refresher {
        let remote = try AccountDomain.getAccountDomains()
        let sync = AccountDomain.syncSignalProducer(inContext: context, fetchRemote: remote)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: RefreshScope.global, cacheKey: cacheKey(context))
    }
}
