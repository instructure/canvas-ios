//
//  Conversation.swift
//  Messages
//
//  Created by Nathan Armstrong on 6/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
import SoPersistent
import SoLazy
import Marshal

final public class Conversation: NSManagedObject, Model {
    // MARK: Types

    public enum WorkflowState: String {
        case Unread = "unread"
        case Read = "read"
    }

    // MARK: Properties

    @NSManaged public private (set) var id: String

    /**
     The date that the most recent message was sent.
     */
    @NSManaged public private (set) var date: NSDate

    /**
     The subject of the conversation.
     */
    @NSManaged public private (set) var subject: String

    /**
     The content of the most recent message.
     */
    @NSManaged public private (set) var mostRecentMessage: String

    /**
     The participant that sent the most recent message not sent by the current user.
     */
    public var mostRecentSender: Participant {
        return audience.firstObject as! Participant
    }

    /**
     The number of participants in the conversation. Does not include the current user.
     */
    public var numberOfParticipants: Int {
        return audience.count
    }

    /**
     The avatar urls for those participating in the conversation starting with the most recent sender.
     */
    public var participantAvatars: [String] {
        return (audience.array as? [Participant])?.map { $0.avatarURL } ?? []
    }

    /**
     The current state of the conversation.
     */
    public var workflowState: WorkflowState {
        get {
            willAccessValueForKey("workflowState")
            let value = WorkflowState(rawValue: primitiveWorkflowState)!
            didAccessValueForKey("workflowState")
            return value
        }
        set {
            willChangeValueForKey("workflowState")
            primitiveWorkflowState = newValue.rawValue
            didChangeValueForKey("workflowState")
        }
    }

    /**
     A Boolean indicating whether the conversation has attachments.
     */
    @NSManaged public private (set) var hasAttachments: Bool

    /**
     A Boolean indicating whether the conversation is starred.
     */
    @NSManaged public private (set) var starred: Bool

    @NSManaged private var primitiveWorkflowState: String
    @NSManaged private var audience: NSOrderedSet
}

extension Conversation: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        date = try json <| "last_message_at"
        subject = try json <| "subject"
        mostRecentMessage = try json <| "last_message"
        workflowState = try json <| "workflow_state"
        starred = try json <| "starred"

        try updateProperties(with: json)
        try updateAudience(with: json, in: context)
    }

    func updateAudience(with json: JSONObject, in context: NSManagedObjectContext) throws {
        let audienceIDs = try json.stringIDs("audience")
        let participants: [JSONObject] = try json <| "participants"
        let audience = try participants
            .filter { audienceIDs.contains(try $0.stringID("id")) } // removes current user
            .map { try Participant.from(json: $0, in: context) }
        self.audience = NSOrderedSet(array: audience)
    }

    func updateProperties(with json: JSONObject) throws {
        let properties: [String] = try json <| "properties"
        hasAttachments = properties.contains("attachments")
    }
}
