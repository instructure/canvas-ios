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


public enum MasteryPathAssignmentType: String {
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

public final class MasteryPathAssignment: NSManagedObject {

    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var assignmentSetID: String
    @NSManaged internal (set) public var overrideID: String?
    @NSManaged internal (set) public var position: Int64
    @NSManaged internal (set) public var name: String
    @NSManaged internal (set) public var details: String
    @NSManaged internal (set) public var pointsPossible: Double
    @NSManaged internal (set) public var due: Date?

    internal (set) public var type: MasteryPathAssignmentType {
        get {
            willAccessValue(forKey: "type")
            let value = MasteryPathAssignmentType(rawValue: primitiveType)!
            didAccessValue(forKey: "type")
            return value
        }
        set {
            willChangeValue(forKey: "type")
            primitiveType = newValue.rawValue
            didChangeValue(forKey: "type")
        }
    }
    @NSManaged fileprivate var primitiveType: String

    @NSManaged internal (set) public var assignmentSet: MasteryPathAssignmentSet
}

import Marshal

extension MasteryPathAssignment: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id                  = try json.stringID("id")
        assignmentID        = try json.stringID("assignment_id")
        assignmentSetID     = try json.stringID("assignment_set_id")
        overrideID          = try json.stringID("override_id")
        position            = try json <| "position"

        let model: JSONObject = try json <| "model"
        name                = try model <| "name"
        due                 = try model <| "due_at"
        details             = (try model <| "description") ?? ""
        pointsPossible      = (try model <| "points_possible") ?? 0

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
