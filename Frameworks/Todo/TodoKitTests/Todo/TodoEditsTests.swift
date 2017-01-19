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
        let todo = Todo.build(context, id: "12345", done: false, ignoreURL: "https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_9536420/submitting?permanent=0")
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
        let todo = Todo.build(context, id: "12345", done: false, ignoreURL: "https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_314159/submitting?permanent=0")
        try! context.save()

        session.playback("mark-todo-as-done-fails", in: currentBundle) {
            waitUntil { done in
                todo.markAsDone(session) { _ in done() }
            }
        }

        XCTAssertFalse(todo.done)
    }
}
