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
import CoreData
import ReactiveSwift
import SoPersistent
import Marshal

let remoteBagels: [JSONObject] = [
    ["id": "plain", "name": "Plain"],
    ["id": "poppy", "name": "Poppy"],
    ["id": "sesame", "name": "Sesame"],
    ["id": "egg", "name": "Egg"],
    ["id": "cinnamon Raisin", "name": "Cinnamon Raisin"],
    ["id": "everything", "name": "Everything"],
    ["id": "egg-everything", "name": "Egg Everything"],
    ["id": "onion", "name": "Onion"],
    ["id": "salt", "name": "Salt"],
    ["id": "pumpernickel", "name": "Pumpernickel"],
]

extension Bagel {
    @objc
    var favoriteSection: String {
        return isFavorite ? "Da Best" : "Da Rest"
    }
    
    static func allByFavorite(in context: NSManagedObjectContext) throws -> FetchedCollection<Bagel> {
        return try FetchedCollection(frc: context.fetchedResults(nil, sortDescriptors: ["isFavorite".descending, "name".ascending], sectionNameKeypath: "favoriteSection"))
    }
    
    static func favorites(in context: NSManagedObjectContext) throws -> FetchedCollection<Bagel> {
        let onlyFavorites = NSPredicate(format: "%K == true", "isFavorite")
        return try FetchedCollection(frc: context.fetchedResults(onlyFavorites, sortDescriptors: ["name".ascending]))
    }
    
    static func refresh(in context: NSManagedObjectContext) -> Refresher {
        let sync = syncSignalProducer(inContext: context, fetchRemote: SignalProducer<[JSONObject], NSError>([remoteBagels]))
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: .global, cacheKey: "bagels")
    }
    
    typealias TableViewController = FetchedTableViewController<Bagel>
    typealias CollectionViewController = FetchedCollectionViewController<Bagel>
}
