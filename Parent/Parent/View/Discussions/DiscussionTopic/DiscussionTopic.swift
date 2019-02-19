//
// Copyright (C) 2016-present Instructure, Inc.
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

public enum DiscussionTopicType: String {
    case SideComment = "side_comment"
    case Threaded = "threaded"
}

public final class DiscussionTopic: NSManagedObject, LockableModel {
    @NSManaged internal (set) public var id: String          // The ID of this topic
    @NSManaged internal (set) public var title: String       // The topic title
    @NSManaged internal (set) public var message: String     // The HTML content of the message body
    @NSManaged internal (set) public var username: String    // The username of the topic creator
    @NSManaged internal (set) public var htmlURL: URL      // The URL to the discussion topic in canvas
    @NSManaged internal (set) public var postedAt: Date?   // The datetime if the topic was posted.
    @NSManaged internal (set) public var isAnnouncement: Bool   // Announcements are just discussions in disguise

    @NSManaged fileprivate var primitiveType: String
    internal (set) public var type: DiscussionTopicType {
        get {
            willAccessValue(forKey: "type")
            let value = DiscussionTopicType(rawValue: primitiveType) ?? .SideComment
            didAccessValue(forKey: "type")
            return value
        }
        set {
            willChangeValue(forKey: "type")
            primitiveType = newValue.rawValue
            didChangeValue(forKey: "type")
        }
    }

    @NSManaged internal (set) public var requiresInitialPost: Bool   // If true then a user needs to make an initial reply before doing anything else
    @NSManaged internal (set) public var isRead: Bool                // Whether or not the current user has read this topic
    @NSManaged internal (set) public var unreadCount: Int16          // The count of unread entries of this topic
    @NSManaged internal (set) public var pinned: Bool                // Whether or not the topic has been pinned by an instructor
    @NSManaged internal (set) public var assignmentID: String?       // The id of the assignment if the topic is for grading
    @NSManaged internal (set) public var closedForComments: Bool     // Whether or not this is closed for additional comments

    // TODO: Make protocol for publishing, like LockableModel
    @NSManaged internal (set) public var published: Bool     // Whether this discussion topic is published (true) or draft state (false)

    // Parent only cares about the first attachment's name
    @NSManaged internal (set) public var attachmentName: String?
    /// MARK: Locking
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var canView: Bool
}

import Marshal


extension DiscussionTopic: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        title           = try json <| "title"
        message         = try json <| "message"
        username        = try json <| "user_name"
        htmlURL         = try json <| "url"
        postedAt        = try json <| "posted_at"

        willChangeValue(forKey: "type")
        primitiveType = try json <| "discussion_type"
        didChangeValue(forKey: "type")

        requiresInitialPost = (try json <| "require_initial_post") ?? false

        let readState: String   = try json <| "read_state"
        isRead                  = readState == "read"

        unreadCount         = try json <| "unread_count"
        pinned              = try json <| "pinned"
        assignmentID = try json.stringID("assignment_id")
        closedForComments   = try json <| "locked"
        published           = try json <| "published"

        try updateLockStatus(json)

        let attachmentsJSON: [JSONObject] = (try json <| "attachments") ?? []
        if let first = attachmentsJSON.first {
            attachmentName = try first <| "display_name"
        }
    }
}

