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
import TooLegit
@testable import SoPersistent
import Result

let currentBundle = NSBundle(forClass: TodoCollectionTest.self)

class TodoCollectionTest: UnitTestCase {

    let session = Session.ivy

    func testFetchAllTodos_itReturnsOnlyTodosThatAreNotDone() {
        attempt {
            let context = try session.todosManagedObjectContext()
            let todoThatIsDone = Todo.build(context, done: true)
            let todoThatIsNotDone = Todo.build(context)

            let collection = try Todo.allTodos(session)

            XCTAssertTrue(collection.contains(todoThatIsNotDone))
            XCTAssertFalse(collection.contains(todoThatIsDone))
        }
    }

    func testFetchAllTodos_itReturnsTheTodosInOrderOfTheAssignmentDueDate() {
        attempt{
            let context = try session.todosManagedObjectContext()
            let todoWithLatestAssignmentDueDate = Todo.build(context, assignmentDueDate: NSDate(timeIntervalSinceNow:400))
            let todoWithEarliestAssignmentDueDate = Todo.build(context, assignmentDueDate: NSDate(timeIntervalSinceNow:100))
            let todoWithMiddleAssignmentDueDate = Todo.build(context, assignmentDueDate: NSDate(timeIntervalSinceNow:200))

            let collection = try Todo.allTodos(session)

            guard collection.fetchedResultsController.fetchedObjects!.count == 3 else {
                XCTFail("should be three items in collection, found \(collection.fetchedResultsController.fetchedObjects!.count)")
                return
            }

            XCTAssertEqual(collection[pathForRow(0)], todoWithEarliestAssignmentDueDate)
            XCTAssertEqual(collection[pathForRow(1)], todoWithMiddleAssignmentDueDate)
            XCTAssertEqual(collection[pathForRow(2)], todoWithLatestAssignmentDueDate)
        }
    }

    func testFetchAllTodos_itReturnsTheTodosInOrderOfTheAssignmentNameIfDatesAreEqual() {
        attempt{
            let date = NSDate(timeIntervalSinceNow:400)
            let context = try session.todosManagedObjectContext()
            let todoWithLatestAssignmentName = Todo.build(context, assignmentDueDate: date, assignmentName: "c")
            let todoWithEarliestAssignmentName = Todo.build(context, assignmentDueDate: date, assignmentName: "a")
            let todoWithMiddleAssignmentName = Todo.build(context, assignmentDueDate: date, assignmentName: "b")

            let collection = try Todo.allTodos(session)

            guard collection.fetchedResultsController.fetchedObjects!.count == 3 else {
                XCTFail("should be three items in collection, found \(collection.fetchedResultsController.fetchedObjects!.count)")
                return
            }

            XCTAssertEqual(collection[pathForRow(0)], todoWithEarliestAssignmentName)
            XCTAssertEqual(collection[pathForRow(1)], todoWithMiddleAssignmentName)
            XCTAssertEqual(collection[pathForRow(2)], todoWithLatestAssignmentName)
        }
    }

    func pathForRow(row: Int) -> NSIndexPath {
        return NSIndexPath(forRow: row, inSection: 0)
    }

    func testRefresher_itSyncsAllTodos() {
        attempt {
            let context = try session.todosManagedObjectContext()
            let refresher = try Todo.refresher(session)

            assertDifference({ Todo.count(inContext: context) }, 3) {
                refresher.playback("todos", in: currentBundle, with: session)
            }

        }
    }
}
