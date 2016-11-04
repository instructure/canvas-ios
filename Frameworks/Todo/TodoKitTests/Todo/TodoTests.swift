
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
    
    

@testable import TodoKit
import SoAutomated
import Marshal
import AssignmentKit
import TooLegit

class TodoTests: UnitTestCase {

    func testValid() {
        attempt {
            let session = Session.inMemory
            let context = try session.todosManagedObjectContext()
            let todo = Todo.build(context)
            XCTAssert(todo.isValid)
        }
    }

    func testUpdateValues_itSetsTheObjectPropertiesTheCorrespondingJSONValues() {
        attempt {
            let bundle = NSBundle(forClass: TodoTests.self)
            let data = NSData(contentsOfFile: bundle.pathForResource("todo", ofType: "json")!)!
            let json = try JSONParser.JSONObjectWithData(data)
            let session = Session.inMemory
            let context = try session.todosManagedObjectContext()
            
            let todo = Todo(inContext: context)
            try todo.updateValues(json, inContext: context)
            
            XCTAssertEqual("9536420", todo.id)
            XCTAssertEqual("submitting", todo.type)
            XCTAssertEqual("https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_9536420/submitting?permanent=0", todo.ignoreURL)
            XCTAssertEqual("https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_9536420/submitting?permanent=1", todo.ignorePermanentURL)
            XCTAssertEqual("https://mobiledev.instructure.com/courses/1863668/assignments/9536420#submit", todo.htmlURL)
            XCTAssertNil(todo.needsGradingCount)
            
            XCTAssertEqual("9536420", todo.assignmentID)
            XCTAssertEqual("Check WWDC Status : April 25, 2016", todo.assignmentName)
            XCTAssertNotNil(todo.assignmentDueDate)
            let equal = NSDate.fromISO8601String("2016-04-26T05:59:00Z")!
            XCTAssert(todo.assignmentDueDate?.isEqualToDate(equal) ?? false)
            XCTAssertEqual("https://mobiledev.instructure.com/courses/1863668/assignments/9536420", todo.assignmentHtmlURL)
            
            XCTAssertEqual([.Text], todo.submissionTypes)
            XCTAssertEqual("1863668", todo.contextID.id)
        }
    }
    
    func testUpdateValues_itSetsTheAssignmentHtmlURLToTheQuizURL() {
        attempt {
            let bundle = NSBundle(forClass: TodoTests.self)
            let data = NSData(contentsOfFile: bundle.pathForResource("todo", ofType: "json")!)!
            var json = try JSONParser.JSONObjectWithData(data)
            let session = Session.inMemory
            let context = try session.todosManagedObjectContext()
            
            var assignment: JSONObject = try json <| "assignment"
            assignment["quiz_id"] = 1
            assignment["submission_types"] = ["online_text_entry", "online_quiz"]
            json["assignment"] = assignment
            
            let todo = Todo(inContext: context)
            try todo.updateValues(json, inContext: context)
            
            XCTAssertEqual("https://mobiledev.instructure.com/courses/1863668/assignments/9536420", todo.assignmentHtmlURL)
        }
    }
    
    func testRoutingURL_itReturnsTheCorrectURL() {
        attempt {
            let session = Session.inMemory
            let context = try session.todosManagedObjectContext()
            let todo = Todo.build(context, assignmentHtmlURL: "https://mob.instructure.com/courses/1/assignments/2")
            
            // quiz
            todo.submissionTypes = [.Quiz]
            XCTAssertEqual("https://mob.instructure.com/courses/1/assignments/2", todo.routingURL)
            
            // discussion
            todo.submissionTypes = [.DiscussionTopic]
            XCTAssertEqual("https://mob.instructure.com/courses/1/assignments/2", todo.routingURL)
            
            // everything else
            todo.submissionTypes = .None
            XCTAssertEqual("https://mob.instructure.com/courses/1/assignments/2", todo.routingURL)
        }
    }
    
}
