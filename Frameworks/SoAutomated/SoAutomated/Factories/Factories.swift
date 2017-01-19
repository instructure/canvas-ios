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
    
    

import SoPersistent
import TooLegit
import CoreData

public typealias Stub = String

func defineLockedStatus(_ object: LockableModel) {
    object.lockedForUser = false
    object.canView = true
    object.lockExplanation = nil
}

// MARK: - EnrollmentKit

@testable import EnrollmentKit

extension Course: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .enrollmentKit }
    public static func define(_ object: Course) {
        object.id = "1"
        object.name = "One"
        object.code = "one"
        object.isFavorite = false
    }
}

extension Group: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .enrollmentKit }
    public static func define(_ object: Group) {
        object.id = "1"
        object.name = "one"
        object.isFavorite = false
    }
}

extension Tab: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .enrollmentKit }
    public static func define(_ object: Tab) {
        object.id = "1"
        object.rawContextID = ContextID(id: "1", context: .course).canvasContextID
        object.label = "Tab"
        object.position = 0
    }
}

extension Grade: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .enrollmentKit }
    public static func define(_ object: Grade) {
        object.course = Course.build(inContext: object.managedObjectContext!)
    }
}

extension GradingPeriod: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .enrollmentKit }
    public static func define(_ object: GradingPeriod) {
        object.id = "1"
        object.title = "Period 1"
        object.courseID = "1"
        object.startDate = Date()
    }
}

// MARK: - AssignmentKit

@testable import AssignmentKit

extension Rubric: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .assignmentKit }
    public static func define(_ object: Rubric) {}
}

extension Assignment: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .assignmentKit }
    public static func define(_ object: Assignment) {
        object.id = "1"
        object.courseID = "1"
        object.name = "Assignment 1"
        object.details = ""
        object.htmlURL = URL(string: "http://canvas.example.com/courses/1/assignments/1")!
        object.submissionTypes = [.text]
    }
}

extension AssignmentGroup: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return.assignmentKit }
    public static func define(_ object: AssignmentGroup) {
        object.id = "1"
        object.name = "Assignments"
        object.position = 0
        object.weight = 0.0
        object.assignments = []
    }
}

extension Submission: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return.assignmentKit }
    public static func define(_ object: Submission) {
        object.rawSubmissionType = "online_upload"
    }
}

// MARK: - FileKit

@testable import FileKit

extension Folder: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .fileKit }
    public static func define(_ object: Folder) {
        object.id = "1"
        object.contextID = ContextID(id: "1", context: .user)
        object.name = "New Folder"
    }
}

extension File: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .fileKit }
    public static func define(_ object: File) {
        object.id = "1"
        object.contextID = ContextID(id: "1", context: .user)
        object.name = "New File"
    }
}

// MARK: - SoEdventurous

@testable import SoEdventurous

extension Module: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .soEdventurous }
    public static func define(_ object: Module) {
        object.id = "1"
        object.courseID = "1"
        object.name = "Module 1"
        object.position = 0
    }
}

extension ModuleItem: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .soEdventurous }
    public static func define(_ object: ModuleItem) {
        object.id = "1"
        object.courseID = "1"
        object.moduleID = "1"
        object.position = 0
        object.title = "Module Item 1"
        object.contentType = .assignment
        object.content = .assignment(id: "1")
        object.completed = false
    }
}

extension MasteryPathsItem {
    public static func factory(inSession session: Session, customize: (MasteryPathsItem) -> Void = { _ in }) -> MasteryPathsItem {
        let object = factory(auto_managedObjectContext.value(session))
        customize(object)
        return object
    }

    static func factory(_ context: NSManagedObjectContext) -> MasteryPathsItem {
        let object: MasteryPathsItem = create(inContext: context)
        ModuleItem.define(object)
        object.moduleItemID = "1"
        object.defineLockedStatus()
        return object
    }
}

extension MasteryPathAssignmentSet: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .soEdventurous }
    public static func define(_ object: MasteryPathAssignmentSet) {
        object.id = "1"
        object.position = 0
    }
}

// MARK: - SuchActivity

@testable import SuchActivity

extension Activity: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .suchActivity }
    public static func define(_ object: Activity) {
        object.id = "1"
        object.title = "Some activity"
        object.message = "Some activity's deets"
        object.createdAt = Date()
        object.updatedAt = Date()
        object.type = .submission
    }
}
