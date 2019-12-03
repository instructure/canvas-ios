//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core
import TestsFoundation

class SyllabusActionableItemsPresenterTests: CoreTestCase {

    var resultingError: NSError?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: SyllabusActionableItemsPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var colorExpectation = XCTestExpectation(description: "expectation")
    var models: [SyllabusActionableItemsViewController.ViewModel] = []

    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    var title: String?
    var color: UIColor?
    var originalTimeZone: TimeZone!

    override func setUp() {
        super.setUp()
        originalTimeZone = NSTimeZone.default
        expectation = XCTestExpectation(description: "expectation")
        presenter = SyllabusActionableItemsPresenter(env: environment, view: self, courseID: "1")
    }

    override func tearDown() {
        NSTimeZone.default = originalTimeZone
        super.tearDown()
    }

    func testUseCasesSetupProperly() {
        XCTAssertEqual(presenter.course.useCase.courseID, presenter.courseID)

        XCTAssertEqual(presenter.assignments.useCase.courseID, presenter.courseID)
        XCTAssertEqual(presenter.assignments.useCase.sort, .dueAt)

        XCTAssertEqual(presenter.calendarEvents.useCase.context.contextType, .course)
        XCTAssertEqual(presenter.calendarEvents.useCase.context.id, presenter.courseID)
    }

    func testLoadColors() {
        let course = Course.make()
        ContextColor.make(canvasContextID: course.canvasContextID)

        presenter.color.eventHandler()

        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadAssignments() {
        let assignment = Assignment.make(from: .make(course_id: "1"))
        assignment.syllabus = Syllabus.make(courseID: "1", in: databaseClient)
        // the update method on the view is only called if both events fire twice
        presenter.assignments.eventHandler()
        presenter.assignments.eventHandler()
        presenter.calendarEvents.eventHandler()
        presenter.calendarEvents.eventHandler()
        XCTAssertEqual(models[0].title, assignment.name)
    }

    func testLoadCalendarEvents() {
        let calendarEvent = CalendarEventItem.make()
        // the update method on the view is only called if both events fire twice
        presenter.assignments.eventHandler()
        presenter.assignments.eventHandler()
        presenter.calendarEvents.eventHandler()
        presenter.calendarEvents.eventHandler()
        XCTAssertEqual(models[0].title, calendarEvent.title)
    }

    func testSelect() {
        let htmlURL = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let router = environment.router as? TestRouter
        XCTAssertNoThrow(presenter.select(htmlURL, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(htmlURL))
    }

    func testFormattedDateNoDueDate() {
        let str = presenter.formattedDueDate(nil)
        XCTAssertEqual(str, "No Due Date")
    }

    func testFormattedDate() {
        NSTimeZone.default = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        let date = Date(fromISOString: "2018-05-15T20:00:00Z")
        let str = presenter.formattedDueDate(date)
        XCTAssertEqual(str, "May 15, 2018 at 8:00 PM")
    }

    func testSortOrder() {
        let syllabus = Syllabus.make(courseID: "1", in: databaseClient)
        Assignment.make(from: .make(id: "1", name: "a", due_at: Date(fromISOString: "2017-05-15T20:00:00Z")), syllabus: syllabus)
        Assignment.make(from: .make(id: "2", name: "b", due_at: Date(fromISOString: "2018-05-15T20:00:00Z")), syllabus: syllabus)
        Assignment.make(from: .make(id: "3", name: "c", due_at: nil), syllabus: syllabus)

        CalendarEventItem.make(from: .make(id: "1", title: "cA", end_at: Date(fromISOString: "2016-05-15T20:00:00Z")))
        CalendarEventItem.make(from: .make(id: "2", title: "cB", end_at: Date(fromISOString: "2017-06-15T20:00:00Z")))
        CalendarEventItem.make(from: .make(id: "3", title: "cC", end_at: nil))

        // the update method on the view is only called if both events fire twice
        presenter.assignments.eventHandler()
        presenter.assignments.eventHandler()
        presenter.calendarEvents.eventHandler()
        presenter.calendarEvents.eventHandler()

        let order = models.map { $0.title }
        XCTAssertEqual(order, ["cA", "a", "cB", "b", "c", "cC"])
    }

    func testDoesNotDeleteAssignments() {
        environment.mockStore = false
        api.mock(presenter.assignments, value: [])
        let assignment = Assignment.make(from: .make(id: "1", course_id: "1"))
        presenter.viewIsReady()
        XCTAssertFalse(databaseClient.isObjectDeleted(assignment))
    }
}

extension SyllabusActionableItemsPresenterTests: SyllabusActionableItemsViewProtocol {
    func updateColor(_ color: UIColor?) {
        resultingBackgroundColor = color
        colorExpectation.fulfill()
    }

    func update(models: [SyllabusActionableItemsViewController.ViewModel]) {
        self.models = models
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
