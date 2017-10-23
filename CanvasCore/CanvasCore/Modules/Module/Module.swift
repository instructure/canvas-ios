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
    internal (set) open var prerequisiteModuleIDs: [String] {
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

    open var hasPrerequisites: Bool {
        return !prerequisiteModuleIDs.isEmpty
    }
}


import Marshal

extension Module: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
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

    func updateState(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
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
