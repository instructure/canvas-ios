//
//  Panda.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 1/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoAutomated
import TooLegit
import SoLazy

protocol PandaProtocol {
    var id: String { get }
    var name: String { get }
    var birthday: NSDate { get }
}

final class Panda: NSManagedObject, PandaProtocol {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var birthday: NSDate

    var firstLetterOfName: String {
        return name.substringToIndex(name.startIndex.advancedBy(1))
    }

}

extension Panda: Model {}

// MARK: - SynchronizedModel

import SoPersistent
import Marshal

extension Panda: SynchronizedModel {

    static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        name = try json <| "name"
        birthday = try json <| "birthday"
    }

}
