
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
