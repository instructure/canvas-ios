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

func defineLockedStatus(object: LockableModel) {
    object.lockedForUser = false
    object.canView = true
    object.lockExplanation = nil
}

// MARK: - EnrollmentKit

@testable import EnrollmentKit

extension Course: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .EnrollmentKit }
    public static func define(object: Course) {
        object.id = "1"
        object.name = "One"
        object.code = "one"
        object.isFavorite = false
    }
}

extension Group: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .EnrollmentKit }
    public static func define(object: Group) {
        object.id = "1"
        object.name = "one"
        object.isFavorite = false
    }
}

extension Tab: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .EnrollmentKit }
    public static func define(object: Tab) {
        object.id = "1"
        object.rawContextID = ContextID(id: "1", context: .Course).canvasContextID
        object.label = "Tab"
        object.position = 0
    }
}

extension Grade: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .EnrollmentKit }
    public static func define(object: Grade) {
        object.course = Course.build(inContext: object.managedObjectContext!)
    }
}

extension GradingPeriod: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .EnrollmentKit }
    public static func define(object: GradingPeriod) {
        object.id = "1"
        object.title = "Period 1"
        object.courseID = "1"
        object.startDate = NSDate()
    }
}

// MARK: - AssignmentKit

@testable import AssignmentKit

extension Rubric: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .AssignmentKit }
    public static func define(object: Rubric) {}
}

extension Assignment: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .AssignmentKit }
    public static func define(object: Assignment) {
        object.id = "1"
        object.courseID = "1"
        object.name = "Assignment 1"
        object.details = ""
        object.htmlURL = NSURL(string: "http://canvas.example.com/courses/1/assignments/1")!
        object.submissionTypes = [.Text]
    }
}

extension AssignmentGroup: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .AssignmentKit }
    public static func define(object: AssignmentGroup) {
        object.id = "1"
        object.name = "Assignments"
        object.position = 0
        object.weight = 0.0
        object.assignments = []
    }
}

extension Submission: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .AssignmentKit }
    public static func define(object: Submission) {
        object.rawSubmissionType = "online_upload"
    }
}

// MARK: - FileKit

@testable import FileKit

extension Folder: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .FileKit }
    public static func define(object: Folder) {
        object.id = "1"
        object.contextID = ContextID(id: "1", context: .User)
        object.name = "New Folder"
    }
}

extension File: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .FileKit }
    public static func define(object: File) {
        object.id = "1"
        object.contextID = ContextID(id: "1", context: .User)
        object.name = "New File"
    }
}

// MARK: - SoEdventurous

@testable import SoEdventurous

extension Module: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .SoEdventurous }
    public static func define(object: Module) {
        object.id = "1"
        object.courseID = "1"
        object.name = "Module 1"
        object.position = 0
    }
}

extension ModuleItem: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .SoEdventurous }
    public static func define(object: ModuleItem) {
        object.id = "1"
        object.courseID = "1"
        object.moduleID = "1"
        object.position = 0
        object.title = "Module Item 1"
        object.contentType = .assignment
        object.content = .Assignment(id: "1")
        object.completed = false
    }
}

extension MasteryPathsItem {
    public static func factory(inSession session: Session, customize: (MasteryPathsItem) -> Void = { _ in }) -> MasteryPathsItem {
        let object = factory(auto_managedObjectContext.value(session))
        customize(object)
        return object
    }

    static func factory(context: NSManagedObjectContext) -> MasteryPathsItem {
        let object: MasteryPathsItem = create(inContext: context)
        ModuleItem.define(object)
        object.moduleItemID = "1"
        object.locked = true
        object.defineLockedStatus()
        return object
    }
}

extension MasteryPathAssignmentSet: ManagedFactory {
    public static var auto_managedObjectContext: ManagedObjectContext { return .SoEdventurous }
    public static func define(object: MasteryPathAssignmentSet) {
        object.id = "1"
        object.position = 0
    }
}
