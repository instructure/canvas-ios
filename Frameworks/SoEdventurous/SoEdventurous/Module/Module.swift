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
import SoLazy

public class Module: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var courseID: String // This is not in the json, but set in the refresher
    @NSManaged internal (set) public var name: String
    @NSManaged internal (set) public var position: Int
    @NSManaged internal (set) public var requireSequentialProgress: Bool
    @NSManaged internal (set) public var itemCount: Int
    @NSManaged internal (set) public var unlockDate: NSDate?
    @NSManaged internal (set) public var completionDate: NSDate?

    @NSManaged private var primitivePrerequisiteModuleIDs: String
    internal (set) public var prerequisiteModuleIDs: [String] {
        get {
            willAccessValueForKey("prerequisiteModuleIDs")
            let value = primitivePrerequisiteModuleIDs.componentsSeparatedByString(",").filter { !$0.isEmpty }
            didAccessValueForKey("prerequisiteModuleIDs")
            return value
        }
        set {
            willChangeValueForKey("prerequisiteModuleIDs")
            primitivePrerequisiteModuleIDs = newValue.joinWithSeparator(",")
            didChangeValueForKey("prerequisiteModuleIDs")
        }
    }

    public enum State: String {
        case locked = "locked"
        case unlocked = "unlocked"
        case started = "started"
        case completed = "completed"
    }
    @NSManaged private var primitiveState: String?

    internal (set) public var state: State? {
        get {
            willAccessValueForKey("state")
            let value = primitiveState.flatMap(State.init)
            didAccessValueForKey("state")
            return value
        }
        set {
            willChangeValueForKey("state")
            primitiveState = newValue?.rawValue
            didChangeValueForKey("state")
        }
    }

    public enum WorkflowState: String {
        case active = "active"
        case deleted = "deleted"
    }
    @NSManaged private var primitiveWorkflowState: String?
    internal (set) public var workflowState: WorkflowState? {
        get {
            willAccessValueForKey("workflowState")
            var value: WorkflowState? = nil
            if let primitiveWorkflowState = primitiveWorkflowState {
                value = WorkflowState(rawValue: primitiveWorkflowState)
            }
            didAccessValueForKey("workflowState")
            return value
        }
        set {
            willChangeValueForKey("workflowState")
            primitiveWorkflowState = newValue?.rawValue
            didChangeValueForKey("workflowState")
        }
    }

    public var hasPrerequisites: Bool {
        return !prerequisiteModuleIDs.isEmpty
    }
}


import Marshal

extension Module: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id                          = try json.stringID("id")
        courseID                    = try json.stringID("course_id")
        name                        = try json <| "name"
        position                    = try json <| "position" ?? 1
        requireSequentialProgress   = try json <| "require_sequential_progress" ?? false
        itemCount                   = try json <| "items_count" ?? 0
        unlockDate                  = try json <| "unlock_at"
        completionDate              = try json <| "completed_at"
        prerequisiteModuleIDs       = try json.stringIDs("prerequisite_module_ids")
        workflowState               = try json <| "workflow_state"

        try updateState(json, inContext: context)
    }

    func updateState(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        state = try json <| "state"

        if state == .completed {
            let hasCompletionRequirement: (JSONObject) throws -> Bool = { json in
                let (completionRequirement, _, _) = try ModuleItem.parseCompletionRequirement(json)
                return completionRequirement != nil && completionRequirement != .MustChoose
            }
            let items: [JSONObject] = try json <| "items" ?? []
            if try items.findFirst(hasCompletionRequirement) == nil {
                state = nil
            }
        }
    }
}
