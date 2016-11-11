//
//  MasteryPathAssignment.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent

public final class MasteryPathAssignment: NSManagedObject {
    public enum Type: String {
        case assignment = "assignment"
        case quiz = "quiz"
        case discussionTopic = "discussion_topic"
        case externalTool = "external_tool"

        public var accessibilityLabel: String {
            switch self {
            case .assignment: return NSLocalizedString("assignment", comment: "label to be read for visually impaired users with assignment types")
            case .quiz: return NSLocalizedString("quiz", comment: "label to be read for visually impaired users with quiz assignment types")
            case .discussionTopic: return NSLocalizedString("discussion topic", comment: "label to be read for visually impaired users with discusstion topic assignment types")
            case .externalTool: return NSLocalizedString("external tool", comment: "label to be read for visually impaired users with external tool assignment types")
            }
        }
    }

    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var assignmentSetID: String
    @NSManaged internal (set) public var overrideID: String?
    @NSManaged internal (set) public var position: Int
    @NSManaged internal (set) public var name: String
    @NSManaged internal (set) public var details: String
    @NSManaged internal (set) public var pointsPossible: Double
    @NSManaged internal (set) public var due: NSDate?

    internal (set) public var type: Type {
        get {
            willAccessValueForKey("type")
            let value = Type(rawValue: primitiveType)!
            didAccessValueForKey("type")
            return value
        }
        set {
            willChangeValueForKey("type")
            primitiveType = newValue.rawValue
            didChangeValueForKey("type")
        }
    }
    @NSManaged private var primitiveType: String

    @NSManaged internal (set) public var assignmentSet: MasteryPathAssignmentSet
}

import Marshal

extension MasteryPathAssignment: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id                  = try json.stringID("id")
        assignmentID        = try json.stringID("assignment_id")
        assignmentSetID     = try json.stringID("assignment_set_id")
        overrideID          = try json.stringID("override_id")
        position            = try json <| "position"

        let model: JSONObject = try json <| "model"
        name                = try model <| "name"
        due                 = try model <| "due_at"
        details             = try model <| "description" ?? ""
        pointsPossible      = try model <| "points_possible" ?? 0

        let types: [String] = try model <| "submission_types"
        // Doing something similar to Assignment's icon variable
        if types == ["online_quiz"] {
            type = .quiz
        } else if types == ["external_tool"] {
            type = .externalTool
        } else if types == ["discussion_topic"] {
            type = .discussionTopic
        } else {
            type = .assignment
        }
    }
}
