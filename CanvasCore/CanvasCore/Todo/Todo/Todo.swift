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

import ReactiveCocoa

import Marshal



private let contextIDErrorMessage = NSLocalizedString("There was an error associating a tab with a course or group.", tableName: "Localizable", bundle: .core, value: "", comment: "Error message when parsing contextID for a course or group tab")
private let contextIDFailureReason = NSLocalizedString("Could not parse context id from URL", tableName: "Localizable", bundle: .core, value: "", comment: "Failure reason for why it couldn't associate a tab with a context")

public enum TodoType: String {
    case discussion = "discussion_topic"
    case quiz = "online_quiz"
    case assignment = "assignment"
    case lti = "external_tool"
    
    public var icon: UIImage {
        switch self {
        case .discussion: return .icon(.discussion)
        case .quiz: return .icon(.quiz)
        case .lti: return .icon(.lti)
        case .assignment: return .icon(.assignment)
        }
    }
}

public final class Todo: NSManagedObject {

    // ---------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var done: Bool
    @NSManaged internal (set) public var type: String
    @NSManaged internal (set) public var ignoreURL: String
    @NSManaged internal (set) public var ignorePermanentURL: String
    @NSManaged internal (set) public var htmlURL: String
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var assignmentName: String
    @NSManaged internal (set) public var assignmentDueDate: Date?
    @NSManaged internal (set) public var needsGradingCount: NSNumber?
    @NSManaged internal (set) public var assignmentHtmlURL: String
    @NSManaged internal var primitiveTodoType: String

    @NSManaged fileprivate var primitiveContextID: String
    internal (set) public var contextID: ContextID {
        get {
            willAccessValue(forKey: "contextID")
            let value = ContextID(canvasContext: primitiveContextID)!
            didAccessValue(forKey: "contextID")
            return value
        }
        set {
            willChangeValue(forKey: "contextID")
            primitiveContextID = newValue.canvasContextID
            didChangeValue(forKey: "contextID")
        }
    }

    internal (set) public var todoType: TodoType {
        get {
            willAccessValue(forKey: "todoType")
            defer { didAccessValue(forKey: "todoType") }
            return TodoType(rawValue: primitiveTodoType)!
        } set {
            willChangeValue(forKey: "todoType")
            defer { didChangeValue(forKey: "todoType") }
            primitiveTodoType = newValue.rawValue
        }
    }

}

// MARK: - Core Data
extension Todo: SynchronizedModel {

    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let assignmentID: String = try json.stringID("assignment.id")
        return NSPredicate(format: "%K == %@", "assignmentID", assignmentID)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {

        id                  = try json.stringID("assignment.id")
        type                = try json <| "type"
        ignoreURL           = try json <| "ignore"
        ignorePermanentURL  = try json <| "ignore_permanently"
        htmlURL             = try json <| "html_url"

        needsGradingCount   = try json <| "needs_grading_count"
        assignmentID        = try json.stringID("assignment.id")
        assignmentName      = try json <| "assignment.name"
        assignmentDueDate   = try json <| "assignment.due_at"
        assignmentHtmlURL   = try json <| "assignment.html_url"
        let types: [String] = try json <| "assignment.submission_types"
        
        if types.contains(TodoType.discussion.rawValue) {
            todoType = .discussion
        } else if types.contains(TodoType.lti.rawValue) {
            todoType = .lti
        } else if types.contains(TodoType.quiz.rawValue) {
            todoType = .quiz
        } else {
            todoType = .assignment
        }

        guard let url: URL = try json <| "html_url", let context = ContextID(url: url) else {
            throw NSError(subdomain: "TodoKit", code: 0, sessionID: nil, apiURL: URL(string: "/api/v1/users/self/todo"), title: nil, description: contextIDErrorMessage, failureReason: contextIDFailureReason)
        }

        contextID = context
    }

    public var routingURL: String {
        return assignmentHtmlURL
    }

}
