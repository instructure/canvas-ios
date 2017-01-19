//
//  Bagel.swift
//  EverythingBagel
//
//  Created by Derrick Hathaway on 12/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import Marshal

class Bagel: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var isFavorite: Bool
    @NSManaged var name: String
}

extension Bagel: SynchronizedModel {
    static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        try id = json.stringID("id")
        try isFavorite = (json <| "favorite") ?? false
        try name = json <| "name"
    }
}
