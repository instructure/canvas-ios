//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData


public enum ActivityType: String {
    case discussion = "DiscussionTopic"
    case announcement = "Announcement"
    case conversation = "Conversation"
    case message = "Message"
    case submission = "Submission"
    case conference = "WebConference"
    case collaboration = "Collaboration"
    case assessmentRequest = "AssessmentRequest"
}

public class Activity: NSManagedObject {
    @NSManaged internal(set) public var id: String
    @NSManaged internal(set) public var title: String
    @NSManaged internal(set) public var message: String
    @NSManaged internal(set) public var url: URL
    
    @NSManaged internal(set) public var createdAt: Date
    @NSManaged internal(set) public var updatedAt: Date

    @NSManaged private var primitiveContext: String
    
    internal(set) public var context: ContextID {
        get {
            willAccessValue(forKey: "context")
            defer { didAccessValue(forKey: "context") }
            return ContextID(canvasContext: primitiveContext)!
        } set {
            willChangeValue(forKey: "context")
            defer { didChangeValue(forKey: "context") }
            primitiveContext = newValue.canvasContextID
        }
    }

    @NSManaged private var primitiveType: String
    internal (set) public var type: ActivityType {
        get {
            willAccessValue(forKey: "type")
            let value = ActivityType(rawValue: primitiveType)!
            didAccessValue(forKey: "type")
            return value
        }
        set {
            willChangeValue(forKey: "type")
            primitiveType = newValue.rawValue
            didChangeValue(forKey: "type")
        }
    }
}


import Marshal


extension Activity: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(_ json: JSONObject, inContext moc: NSManagedObjectContext) throws {
        
        id          = try json.stringID("id")
        title       = try (json <| "title") ?? ""
        message     = try (json <| "message") ?? ""
        url         = try json <| "html_url"
        createdAt   = try json <| "created_at"
        updatedAt   = try json <| "updated_at"
        type        = try (json <| "type") ?? .submission
        
        if let contextType: String = try json <| "context_type" {
            switch contextType {
            case "Course":
                context = .course(withID: try json.stringID("course_id"))
            case "Group":
                context = .group(withID: try json.stringID("group_id"))
            default:
                context = .currentUser
            }
        } else {
            context = .currentUser
        }
    }
}

