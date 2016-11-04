
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
import SoPersistent
import Marshal
import ReactiveCocoa
import TooLegit

public final class DiscussionEntry: NSManagedObject {
    @NSManaged private (set) public var id: String
    @NSManaged private (set) public var date: NSDate
    @NSManaged private (set) public var message: String
    @NSManaged private var parentID: String?
    @NSManaged private (set) public var read: Bool
    @NSManaged internal (set) public var topicID: String
    
    @NSManaged var rawContextID: String
    
    internal (set) public var contextID: ContextID {
        get {
            return ContextID(canvasContext: rawContextID)!
        } set {
            rawContextID = newValue.canvasContextID
        }
    }
}


extension DiscussionEntry: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id);
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        
        let readState: String? = try json <| "read_state"

        try id              = json.stringID("id")
        try message         = json <| "message" ?? ""
        try date            = json <| "created_at"
        try parentID        = json.stringID("parent_id")
        read                = readState == "read"
    }
    
    func syncAllReplies(json: JSONObject, contextID: ContextID, topicID: String, inContext context: NSManagedObjectContext) throws {
        typealias DE = DiscussionEntry
        
        let previousEntries: [DiscussionEntry] = try context.findAll(withValue: id, forKey: "parentID")
        var previousSet = Set(previousEntries)
        
        let replies: [JSONObject] = try json <| "replies" ?? []
        
        for reply in replies {
            let entry: DiscussionEntry = try context.findOne(withPredicate: try DE.uniquePredicateForObject(reply))
                ?? DE.create(inContext: context)
            
            try entry.updateValues(reply, inContext: context)
            entry.contextID = contextID
            entry.topicID = topicID
            try entry.syncAllReplies(reply, contextID: contextID, topicID: topicID, inContext: context)

            previousSet.remove(entry)
        }
        
        for deleted in previousSet {
            context.deleteObject(deleted)
        }
    }
}
