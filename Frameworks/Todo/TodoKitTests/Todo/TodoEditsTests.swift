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
import Nimble

class TodoEditTests: UnitTestCase {
    func testMarkAsDone_itMarksTheTodoAsDone() {
        let session = Session.ivy
        let context = try! session.todosManagedObjectContext()
        let todo = Todo.build(context, id: "12345", ignoreURL: "https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_9536420/submitting?permanent=0", done: false)
        try! context.save()

        session.playback("todo-ignore", in: currentBundle) {
            waitUntil { done in
                todo.markAsDone(session) { _ in done() }
            }
        }

        expect(todo.done).toEventually(beTrue())
    }
    
    func testMarkAsDone_whenTheSignalFails_itMarksTheTodoAsNotDone() {
        let session = Session.art
        let context = try! session.todosManagedObjectContext()
        let todo = Todo.build(context, id: "12345", ignoreURL: "https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_314159/submitting?permanent=0", done: false)
        try! context.save()

        session.playback("mark-todo-as-done-fails", in: currentBundle) {
            waitUntil { done in
                todo.markAsDone(session) { _ in done() }
            }
        }

        XCTAssertFalse(todo.done)
    }
}
