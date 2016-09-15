//
//  TodoNetworkTests.swift
//  Todo
//
//  Created by Brandon Pluim on 4/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import TodoKit
import XCTest
import SoAutomated
import Marshal
import TooLegit
import DoNotShipThis

class TodoNetworkTests: UnitTestCase {

    func testGetTodos_itReturnsTheCorrectAmountOfTodos() {
        attempt {
            var todos: [JSONObject]?
            let session = Session.bt

            stub(session, "todos") { expectation in
                try Todo.getTodos(session).startWithCompletedExpectation(expectation) { response in
                    todos = response
                }
            }

            XCTAssertEqual(3, todos?.count)
        }
    }

    func testIgnore_itCompletesTheRequest() {
        attempt {
            let session = Session.ivy
            var response: JSONObject?
            let todo = Todo.build(try session.todosManagedObjectContext(), ignoreURL: "https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_9536420/submitting?permanent=0")
            
            stub(session, "todo-ignore") { expectation in
                try todo.ignore(session).startWithCompletedExpectation(expectation) { json in response = json }
            }
            XCTAssertNotNil(response)
        }
    }

}
