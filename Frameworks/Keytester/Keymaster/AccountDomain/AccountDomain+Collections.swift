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
import TooLegit
import CoreData
import SoPersistent
import SoLazy


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

    public typealias TableViewController = FetchedTableViewController<AccountDomain>
}
