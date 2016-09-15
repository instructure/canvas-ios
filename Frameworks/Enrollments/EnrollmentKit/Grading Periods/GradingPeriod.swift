//
//  GradingPeriod.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/28/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
import SoPersistent
import TooLegit
import Marshal

public final class GradingPeriod: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var title: String
    @NSManaged internal (set) public var courseID: String
    @NSManaged internal (set) public var startDate: NSDate
}

extension GradingPeriod: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        try id          = json.stringID("id")
        try title       = json <| "title"
        try startDate   = json <| "start_date"
    }
}
