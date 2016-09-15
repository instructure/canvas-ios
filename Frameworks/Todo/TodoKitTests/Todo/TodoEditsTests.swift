//
//  TodoEditsTests.swift
//  Todo
//
//  Created by Joseph Davison on 6/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import TodoKit
import Foundation
import SoAutomated
import TooLegit
import SoPersistent
import DoNotShipThis
import ReactiveCocoa

class TodoEditTests: UnitTestCase {

    func testMarkAsDone_itMarksTheTodoAsDone() {
        attempt {
            let session = Session.ivy
            let context = try session.todosManagedObjectContext()
            let todo = Todo.build(context, id: "12345", ignoreURL: "https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_9536420/submitting?permanent=0")
            try context.save()
            let predicate = NSPredicate(format: "%K == %@", "id", todo.id)
            let observer = try ManagedObjectObserver<Todo>(predicate: predicate, inContext: context)

            stub(session, "todo-ignore") { expectation in
                observer.signal.observeNext { _, object in
                    if let todo = object {
                        if todo.done {
                            expectation.fulfill()
                        }
                    }
                }

                todo.markAsDone(session)
            }

            XCTAssertTrue(todo.done)
        }
    }
    
    func testMarkAsDone_whenTheSignalFails_itMarksTheTodoAsNotDone() {
        attempt {
            let session = Session.art
            let context = try session.todosManagedObjectContext()
            let todo = Todo.build(context, id: "12345", ignoreURL: "https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_314159/submitting?permanent=0")
            let predicate = NSPredicate(format: "%K = %@", "id", todo.id)
            let observer = try ManagedObjectObserver<Todo>(predicate: predicate, inContext: context)
            var markedDone = false

            stub(session, "mark-todo-as-done-fails") { expectation in
                observer.signal.observeNext { _, object in
                    if let todo = object {
                        if markedDone && !todo.done {
                            expectation.fulfill()
                        }
                        if todo.done {
                            markedDone = true
                        }
                    }
                }
                
                todo.markAsDone(session)
            }
            
            XCTAssertFalse(todo.done)
        }
    }
    
    
}