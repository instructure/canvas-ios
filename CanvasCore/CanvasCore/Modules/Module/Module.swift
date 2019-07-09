//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import CoreData



open class Module: NSManagedObject {
    @NSManaged internal (set) open var id: String
    @NSManaged internal (set) open var courseID: String // This is not in the json, but set in the refresher
    @NSManaged internal (set) open var name: String
    @NSManaged internal (set) open var position: Int64
    @NSManaged internal (set) open var requireSequentialProgress: Bool
    @NSManaged internal (set) open var itemCount: Int64
    @NSManaged internal (set) open var unlockDate: Date?
    @NSManaged internal (set) open var completionDate: Date?

    @NSManaged fileprivate var primitivePrerequisiteModuleIDs: String
    @objc internal (set) open var prerequisiteModuleIDs: [String] {
        get {
            willAccessValue(forKey: "prerequisiteModuleIDs")
            let value = primitivePrerequisiteModuleIDs.components(separatedBy: ",").filter { !$0.isEmpty }
            didAccessValue(forKey: "prerequisiteModuleIDs")
            return value
        }
        set {
            willChangeValue(forKey: "prerequisiteModuleIDs")
            primitivePrerequisiteModuleIDs = newValue.joined(separator: ",")
            didChangeValue(forKey: "prerequisiteModuleIDs")
        }
    }

    public enum State: String {
        case locked = "locked"
        case unlocked = "unlocked"
        case started = "started"
        case completed = "completed"
    }
    @NSManaged fileprivate var primitiveState: String?

    internal (set) open var state: State? {
        get {
            willAccessValue(forKey: "state")
            let value = primitiveState.flatMap(State.init)
            didAccessValue(forKey: "state")
            return value
        }
        set {
            willChangeValue(forKey: "state")
            primitiveState = newValue?.rawValue
            didChangeValue(forKey: "state")
        }
    }

    public enum WorkflowState: String {
        case active = "active"
        case deleted = "deleted"
    }
    @NSManaged fileprivate var primitiveWorkflowState: String?
    internal (set) open var workflowState: WorkflowState? {
        get {
            willAccessValue(forKey: "workflowState")
            var value: WorkflowState? = nil
            if let primitiveWorkflowState = primitiveWorkflowState {
                value = WorkflowState(rawValue: primitiveWorkflowState)
            }
            didAccessValue(forKey: "workflowState")
            return value
        }
        set {
            willChangeValue(forKey: "workflowState")
            primitiveWorkflowState = newValue?.rawValue
            didChangeValue(forKey: "workflowState")
        }
    }

    @objc open var hasPrerequisites: Bool {
        return !prerequisiteModuleIDs.isEmpty
    }
}


import Marshal

extension Module: SynchronizedModel {
    @objc public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    @objc public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id                          = try json.stringID("id")
        courseID                    = try json.stringID("course_id")
        name                        = try json <| "name"
        position                    = (try json <| "position") ?? 1
        requireSequentialProgress   = (try json <| "require_sequential_progress") ?? false
        itemCount                   = (try json <| "items_count") ?? 0
        unlockDate                  = try json <| "unlock_at"
        completionDate              = try json <| "completed_at"
        prerequisiteModuleIDs       = try json.stringIDs("prerequisite_module_ids")
        workflowState               = try json <| "workflow_state"

        try updateState(json, inContext: context)
    }

    @objc func updateState(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        state = try json <| "state"

        if state == .completed {
            let hasCompletionRequirement: (JSONObject) throws -> Bool = { json in
                let (completionRequirement, _, _) = try ModuleItem.parseCompletionRequirement(json)
                return completionRequirement != nil && completionRequirement != .mustChoose
            }
            let items: [JSONObject] = (try json <| "items") ?? []
            if try items.first(where: hasCompletionRequirement) == nil {
                state = nil
            }
        }
    }
}
