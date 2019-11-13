//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core
@testable import Student
import TestsFoundation

class PeopleListPresenterTests: StudentTestCase {
    var presenter: PeopleListPresenter!

    var resultingBackgroundColor: UIColor?
    var resultingSubtitle: String?

    // To appease ColoredNavViewProtocol
    var color: UIColor?
    var navigationController: UINavigationController?
    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    var expectation = XCTestExpectation(description: "View updated")
    var expectationPredicate: () -> Bool = { true }
    var navbarExpectation = XCTestExpectation(description: "Navbar updated")
    let context = ContextModel(.course, id: "1")

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "View updated")
        navbarExpectation = XCTestExpectation(description: "Navbar updated")
        presenter = PeopleListPresenter(env: env, viewController: self, context: context)
    }

    func testUseCasesSetupProperly() {
        XCTAssertEqual(presenter.course.useCase.courseID, presenter.context.id)
        XCTAssertEqual(presenter.group.useCase.groupID, presenter.context.id)
        XCTAssertEqual(presenter.users.useCase.context.canvasContextID, presenter.context.canvasContextID)
    }

    func testLoadCourseColors() {
        Course.make()
        ContextColor.make()

        presenter.colors.eventHandler()
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadGroupColors() {
        let group = Group.make()
        ContextColor.make(canvasContextID: group.canvasContextID, color: UIColor.blue)

        presenter.colors.eventHandler()
        XCTAssertEqual(resultingBackgroundColor, UIColor.blue)
    }

    func testLoadCourse() {
        let course = Course.make()
        ContextColor.make()

        presenter.course.eventHandler()
        XCTAssertEqual(resultingSubtitle, course.name)
    }

    func testLoadGroup() {
        let group = Group.make()
        ContextColor.make(canvasContextID: group.canvasContextID)

        presenter.group.eventHandler()
        XCTAssertEqual(resultingSubtitle, group.name)
    }

    func testLoadUsers() {
        User.make(from: .make(id: "1", name: "John Doe", sortable_name: "Doe, John"), courseID: context.id)
        User.make(from: .make(id: "2", name: "Jane Doe", sortable_name: "Doe, Jane"), courseID: context.id)

        presenter.users.eventHandler()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(presenter.users.count, 2)
        XCTAssertEqual(presenter.users.first!.id, "2") // Jane
        XCTAssertEqual(presenter.users.last!.id, "1") // John
    }

    func testViewIsReadyCourse() {
        presenter.viewIsReady()
        let colorsStore = presenter.colors as! TestStore
        let usersStore = presenter.users as! TestStore
        let courseStore = presenter.course as! TestStore

        wait(for: [colorsStore.refreshExpectation, usersStore.refreshExpectation, courseStore.refreshExpectation], timeout: 0.1)
    }

    func testViewIsReadyGroup() {
        presenter = PeopleListPresenter(env: env, viewController: self, context: ContextModel(.group, id: "1"))
        presenter.viewIsReady()
        let colorsStore = presenter.colors as! TestStore
        let usersStore = presenter.users as! TestStore
        let groupStore = presenter.group as! TestStore

        wait(for: [colorsStore.refreshExpectation, usersStore.refreshExpectation, groupStore.refreshExpectation], timeout: 0.1)
     }

    func testSendsToContextCard() {
        let user = User.make()
        presenter.select(user: user, from: UIViewController())

        let router = env.router as? TestRouter
        XCTAssertEqual(router?.calls.last?.0, .parse("/courses/1/users/1"))
        XCTAssertEqual(router?.calls.last?.2, [.detail, .embedInNav])
    }
}

extension PeopleListPresenterTests: PeopleListViewProtocol {
    func update() {
        expectation.fulfill()
    }

    func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingBackgroundColor = color
        resultingSubtitle = subtitle
        navbarExpectation.fulfill()
    }
}
