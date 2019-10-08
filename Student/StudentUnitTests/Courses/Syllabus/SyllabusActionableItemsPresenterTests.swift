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
@testable import Student
import Core
import TestsFoundation

class SyllabusActionableItemsPresenterTests: PersistenceTestCase {

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
        presenter = SyllabusActionableItemsPresenter(env: env, view: self, courseID: "1")
    }

    override func tearDown() {
        NSTimeZone.default = originalTimeZone
        super.tearDown()
    }

    func testUseCaseFetchesData() {
        api.mock(GetAssignmentsRequest(courseID: "1", orderBy: .position, include: [], querySize: 100), value: [.make(name: "Assignment One")])
        api.mock(GetCalendarEventsRequest(context: ContextModel(.course, id: "1")), value: [.make(title: "Calendar Event")])

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(presenter.assignments.first?.name, "Assignment One")
        XCTAssertEqual(presenter.calendarEvents.first?.title, "Calendar Event")
    }

    func testLoadCourseColorsAndTitle() {
        //  given
        let expected = Course.make()
        let expectedColor = Color.make()

        //  when
        presenter.viewIsReady()
        XCTAssertEqual(presenter.course.count, 1)
        wait(for: [expectation], timeout: 0.4)
        presenter.loadColor()

        //  then
        XCTAssertEqual(resultingBackgroundColor, expectedColor.color)
        XCTAssertEqual(resultingSubtitle, expected.name)
    }

    func testSelect() {
        let a = Assignment.make()
        let router = env.router as? TestRouter
        XCTAssertNoThrow(presenter.select(a.htmlURL, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(a.htmlURL))
    }

    func testFormattedDateNoDueDate() {
        let a = Assignment.make()
        let str = presenter.formattedDueDate(a.dueAt)
        XCTAssertEqual(str, "No Due Date")
    }

    func testFormattedDate() {
        NSTimeZone.default = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        let a = Assignment.make(from: .make(due_at: Date(fromISOString: "2018-05-15T20:00:00Z")))
        let str = presenter.formattedDueDate(a.dueAt)
        XCTAssertEqual(str, "May 15, 2018 at 8:00 PM")
    }

    func testSortOrder() {
        api.mock(GetAssignmentsRequest(courseID: "1", orderBy: .position, include: [], querySize: 100), value: [
            .make(id: "1", name: "a", due_at: Date(fromISOString: "2017-05-15T20:00:00Z")),
            .make(id: "2", name: "b", due_at: Date(fromISOString: "2018-05-15T20:00:00Z")),
            .make(id: "3", name: "c", due_at: nil),
        ])

        api.mock(GetCalendarEventsRequest(context: ContextModel(.course, id: "1")), value: [
            .make(id: "1", title: "cA", end_at: Date(fromISOString: "2016-05-15T20:00:00Z")),
            .make(id: "2", title: "cB", end_at: Date(fromISOString: "2017-06-15T20:00:00Z")),
            .make(id: "3", title: "cC", end_at: nil),
        ])

        presenter.viewIsReady()

        wait(for: [expectation], timeout: 5)

        let order = models.map { $0.title }
        XCTAssertEqual(order, ["cA", "a", "cB", "b", "c", "cC"])
    }
}

extension SyllabusActionableItemsPresenterTests: SyllabusActionableItemsViewProtocol {
    func update(models: [SyllabusActionableItemsViewController.ViewModel]) {
        self.models = models
        if presenter.course.pending == false && presenter.assignments.pending == false && presenter.calendarEvents.pending == false {
            expectation.fulfill()
        }
    }

    var navigationController: UINavigationController? {
        return UINavigationController(nibName: nil, bundle: nil)
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingBackgroundColor = color
        resultingSubtitle = subtitle
        colorExpectation.fulfill()
    }
}
