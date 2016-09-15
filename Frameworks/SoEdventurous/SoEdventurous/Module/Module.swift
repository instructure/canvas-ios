//
//  Module.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent

public final class Module: NSManagedObject {
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
            let value = primitivePrerequisiteModuleIDs.componentsSeparatedByString(",")
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
        case Locked = "locked"
        case Unlocked = "unlocked"
        case Started = "started"
        case Completed = "completed"
    }
    @NSManaged private var primitiveState: String

    internal (set) public var state: State {
        get {
            willAccessValueForKey("state")
            guard let value = State(rawValue: primitiveState) else { fatalError("invalid state value") }
            didAccessValueForKey("state")
            return value
        }
        set {
            willChangeValueForKey("state")
            primitiveState = newValue.rawValue
            didChangeValueForKey("state")
        }
    }

    public enum WorkflowState: String {
        case Active = "active"
        case Deleted = "deleted"
    }
    @NSManaged private var primitiveWorkflowState: String
    internal (set) public var workflowState: WorkflowState {
        get {
            willAccessValueForKey("workflowState")
            guard let value = WorkflowState(rawValue: primitiveWorkflowState) else { fatalError("invalid workflow state value") }
            didAccessValueForKey("workflowState")
            return value
        }
        set {
            willChangeValueForKey("workflowState")
            primitiveWorkflowState = newValue.rawValue
            didChangeValueForKey("workflowState")
        }
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
        name                        = try json <| "name"
        position                    = try json <| "position" ?? 1
        requireSequentialProgress   = try json <| "require_sequential_progress" ?? false
        itemCount                   = try json <| "items_count" ?? 0
        unlockDate                  = try json <| "unlock_at"
        completionDate              = try json <| "completed_at"
        prerequisiteModuleIDs       = try json.stringIDs("prerequisite_module_ids")

        if let stateValue: String = try json <| "state", s = State(rawValue: stateValue) {
            state = s
        } else {
            state = .Locked
        }

        if let workflowStateValue: String = try json <| "workflow_state", ws = WorkflowState(rawValue: workflowStateValue) {
            workflowState = ws
        } else {
            workflowState = .Active
        }
    }
}
