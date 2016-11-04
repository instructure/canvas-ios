
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
    
    

import CoreData
import SoPersistent
import Marshal

final public class Participant: NSManagedObject {
    @NSManaged public internal (set) var id: String
    @NSManaged public internal (set) var name: String
    @NSManaged public internal (set) var avatarURL: String

    static func from(json json: JSONObject, in context: NSManagedObjectContext) throws -> Participant {
        let participant = Participant(inContext: context)
        participant.id = try json.stringID("id")
        participant.name = try json <| "name"
        participant.avatarURL = try json <| "avatar_url"
        return participant
    }
}
