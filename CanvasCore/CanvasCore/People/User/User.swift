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
    
    

import Foundation
import CoreData

import Marshal


public final class User: NSManagedObject {
    @NSManaged fileprivate (set) public var id: String
    @NSManaged fileprivate (set) public var loginID: String?
    @NSManaged fileprivate (set) public var name: String
    @NSManaged fileprivate (set) public var sortableName: String
    @NSManaged fileprivate (set) public var email: String?
    @NSManaged fileprivate (set) public var avatarURL: URL?
    @NSManaged fileprivate (set) public var obverveeID: String?
}

extension User: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        name            = try json <| "name"
        loginID         = try json <| "login_id"
        sortableName    = try json <| "sortable_name"
        email           = try json <| "primary_email"
        
        if let avatarURLString: String = try json <| "avatar_url" {
            avatarURL   = URL(string: avatarURLString)
        }
    }
}
