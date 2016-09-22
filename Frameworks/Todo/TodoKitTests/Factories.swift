//
//  Factories.swift
//  Todo
//
//  Created by Nathan Armstrong on 5/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
@testable import TodoKit
import TooLegit
import SoAutomated
import SoPersistent
import Marshal
import AssignmentKit

extension Todo {
    static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      done: Bool = false,
                      type: String = "submitting",
                      ignoreURL: String = "",
                      ignorePermanentURL: String = "",
                      htmlURL: String = "",
                      assignmentID: String = "1",
                      assignmentName: String = "Simple Assignment",
                      assignmentDueDate: NSDate? = nil,
                      needsGradingCount: NSNumber? = nil,
                      assignmentHtmlURL: String = "",
                      submissionTypes: SubmissionTypes = [],
                      contextID: ContextID = ContextID(id: "1", context: .Course)
    ) -> Todo {
        let todo = Todo(inContext: context)
        todo.id = id
        todo.done = done
        todo.type = type
        todo.ignoreURL = ignoreURL
        todo.ignorePermanentURL = ignorePermanentURL
        todo.htmlURL = htmlURL
        todo.assignmentID = assignmentID
        todo.assignmentName = assignmentName
        todo.assignmentDueDate = assignmentDueDate
        todo.needsGradingCount = needsGradingCount
        todo.assignmentHtmlURL = assignmentHtmlURL
        todo.submissionTypes = submissionTypes
        todo.contextID = contextID
        return todo
    }
}
