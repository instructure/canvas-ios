//
//  Todo+CollectionTest.swift
//  Todo
//
//  Created by Joseph Davison on 6/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import TodoKit
import SoAutomated
import TooLegit
import SoPersistent
import Result

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

            guard collection.allObjects.count == 3 else {
                XCTFail("should be three items in collection, found \(collection.allObjects.count)")
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

            guard collection.allObjects.count == 3 else {
                XCTFail("should be three items in collection, found \(collection.allObjects.count)")
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
                stub(session, "todos") { expectation in
                    refresher.refreshingCompleted.observeNext(self.refreshCompletedWithExpectation(expectation))
                    refresher.refresh(true)
                }
            }

        }
    }

    class TodoTableViewCellViewModel: TableViewCellViewModel {
        static func tableViewDidLoad(tableView: UITableView) {}
        func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell { return UITableViewCell() }
    }

    func testTableViewControllerPrepare_itInitializesTheProperties() {
        attempt {
            let controller = Todo.TableViewController()
            let collection = try Todo.allTodos(session)
            let refresher = try Todo.refresher(session)
            let detailsFactory: Todo->SimpleTodoDVM = { return SimpleTodoDVM(title: $0.id) }

            controller.prepare(collection, refresher: refresher, viewModelFactory: detailsFactory)

            XCTAssertNotNil(controller.collection)
            XCTAssertNotNil(controller.refresher)
            XCTAssertNotNil(controller.dataSource)
        }
    }
}