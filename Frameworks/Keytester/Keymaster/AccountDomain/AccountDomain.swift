//
//  AccountDomain.swift
//  AccountDomains
//
//  Created by Brandon Pluim on 12/3/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import Foundation

import CoreData

// ---------------------------------------------
// MARK: - Model
// ---------------------------------------------
public final class AccountDomain: NSManagedObject {
    @NSManaged private (set) public var name: String
    @NSManaged private (set) public var domain: String
}

import SoPersistent
import Marshal

// ---------------------------------------------
// MARK: - Synchronized Model
// ---------------------------------------------
extension AccountDomain: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let domain: String = try json <| "domain"
        return NSPredicate(format: "%K == %@", "domain", domain)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        name    = try json <| "name"
        domain  = try json <| "domain"
    }
}