//
//  User.swift
//  Peeps
//
//  Created by Brandon Pluim on 1/13/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import Marshal
import SoLazy

public final class User: NSManagedObject {
    @NSManaged private (set) public var id: String
    @NSManaged private (set) public var loginID: String?
    @NSManaged private (set) public var name: String
    @NSManaged private (set) public var sortableName: String
    @NSManaged private (set) public var email: String?
    @NSManaged private (set) public var avatarURL: NSURL?
    @NSManaged private (set) public var obverveeID: String?
}

extension User: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        name            = try json <| "name"
        loginID         = try json <| "login_id"
        sortableName    = try json <| "sortable_name"
        email           = try json <| "primary_email"

        let avatarURLString: String? = try json <| "avatar_url"
        if let urlString = avatarURLString {
            avatarURL   = NSURL(string: urlString)
        }
    }
}
