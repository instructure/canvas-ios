//
//  AccountDomain+List.swift
//  Keytester
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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
    public static func predicate(searchTerm: String) -> NSPredicate? {
        return (searchTerm.characters.count > 0) ? NSPredicate(format: "%K CONTAINS[c] %@ OR %K CONTAINS[c] %@", "name", searchTerm, "domain", searchTerm) : nil
    }

    public static func collectionBySearchTerm(context: NSManagedObjectContext, searchTerm: String) throws -> FetchedCollection<AccountDomain> {
        let frc = AccountDomain.fetchedResults(predicate(searchTerm), sortDescriptors: ["name".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection<AccountDomain>(frc: frc)
    }

    public static func collection(context: NSManagedObjectContext) throws -> FetchedCollection<AccountDomain> {
        let frc = AccountDomain.fetchedResults(nil, sortDescriptors: ["name".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection<AccountDomain>(frc: frc)
    }

    public static func refresher(context: NSManagedObjectContext) throws -> Refresher {
        let remote = try AccountDomain.getAccountDomains()
        let sync = AccountDomain.syncSignalProducer(inContext: context, fetchRemote: remote)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: RefreshScope.global, cacheKey: cacheKey(context))
    }

    public typealias TableViewController = FetchedTableViewController<AccountDomain>
}
