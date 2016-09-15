//
//  Participant.swift
//  Messages
//
//  Created by Nathan Armstrong on 7/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
import SoPersistent
import Marshal

final public class Participant: NSManagedObject, Model {
    @NSManaged public internal (set) var id: String
    @NSManaged public internal (set) var name: String
    @NSManaged public internal (set) var avatarURL: String

    static func from(json json: JSONObject, in context: NSManagedObjectContext) throws -> Participant {
        let participant = Participant.create(inContext: context)
        participant.id = try json.stringID("id")
        participant.name = try json <| "name"
        participant.avatarURL = try json <| "avatar_url"
        return participant
    }
}
