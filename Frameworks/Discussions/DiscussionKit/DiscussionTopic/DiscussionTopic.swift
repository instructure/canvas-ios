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
import FileKit

public enum DiscussionTopicType: String {
    case SideComment = "side_comment"
    case Threaded = "threaded"
}

public final class DiscussionTopic: NSManagedObject, LockableModel {
    @NSManaged internal (set) public var id: String          // The ID of this topic
    @NSManaged internal (set) public var title: String       // The topic title
    @NSManaged internal (set) public var message: String     // The HTML content of the message body
    @NSManaged internal (set) public var username: String    // The username of the topic creator
    @NSManaged internal (set) public var htmlURL: NSURL      // The URL to the discussion topic in canvas
    @NSManaged internal (set) public var postedAt: NSDate?   // The datetime if the topic was posted.
    @NSManaged internal (set) public var isAnnouncement: Bool   // Announcements are just discussions in disguise

    @NSManaged private var primitiveType: String
    internal (set) public var type: DiscussionTopicType {
        get {
            willAccessValueForKey("type")
            let value = DiscussionTopicType(rawValue: primitiveType) ?? .SideComment
            didAccessValueForKey("type")
            return value
        }
        set {
            willChangeValueForKey("type")
            primitiveType = newValue.rawValue
            didChangeValueForKey("type")
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

    internal (set) public var attachmentIDs: [String] {
        get {
            willAccessValueForKey("attachmentIDs")
            let value = primitiveAttachmentIDs.componentsSeparatedByString(",")
            didAccessValueForKey("attachmentIDs")
            return value
        }
        set {
            willChangeValueForKey("attachmentIDs")
            primitiveAttachmentIDs = newValue.joinWithSeparator(",")
            didChangeValueForKey("attachmentIDs")
        }
    }
    @NSManaged private var primitiveAttachmentIDs: String

    /// MARK: Locking
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var canView: Bool
}

import Marshal
import SoLazy

extension DiscussionTopic: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        title           = try json <| "title"
        message         = try json <| "message"
        username        = try json <| "user_name"
        htmlURL         = try json <| "url"
        postedAt        = try json <| "posted_at"

        willChangeValueForKey("type")
        primitiveType = try json <| "discussion_type"
        didChangeValueForKey("type")

        requiresInitialPost = try json <| "require_initial_post" ?? false

        let readState: String   = try json <| "read_state"
        isRead                  = readState == "read"

        unreadCount         = try json <| "unread_count"
        pinned              = try json <| "pinned"
        assignmentID = try json.stringID("assignment_id")
        closedForComments   = try json <| "locked"
        published           = try json <| "published"

        try updateLockStatus(json)

        let attachmentsJSON: [JSONObject] = try json <| "attachments" ?? []
        let attachments: [File] = try attachmentsJSON.map { json in
            let file: File = (try context.findOne(withPredicate: File.uniquePredicateForObject(json)) as? File) ?? File(inContext: context)
            try file.updateValues(json, inContext: context)
            return file
        }
        self.attachmentIDs = (attachments.map { $0.id })
    }
}
