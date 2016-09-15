//
//  SWPerson.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 4/1/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoAutomated
import TooLegit
import SoLazy

/**
 Star Wars Api Person
 https://swapi.co/documentation#people
 */
protocol SWPersonProtocol {
    var name: String { get }
    var height: String { get }
}

final class SWPerson: NSManagedObject, SWPersonProtocol {
    @NSManaged var name: String
    @NSManaged var height: String
}

// MARK: SynchronizedModel

import SoPersistent
import Marshal

extension SWPerson: Model {}

extension SWPerson: SynchronizedModel {

    static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let name: String = try json <| "name"
        return NSPredicate(format: "%K == %@", "name", name)
    }

    func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        name = try json <| "name"
        height = try json <| "height"
    }

}
