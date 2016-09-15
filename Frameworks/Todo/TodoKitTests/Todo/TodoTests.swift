//
//  TodoTests.swift
//  Todo
//
//  Created by Brandon Pluim on 4/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
            
            let todo = Todo.create(inContext: context)
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
            
            let todo = Todo.create(inContext: context)
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
