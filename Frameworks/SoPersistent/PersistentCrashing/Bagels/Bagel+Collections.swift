//
//  Bagel+Collections.swift
//  EverythingBagel
//
//  Created by Derrick Hathaway on 12/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
