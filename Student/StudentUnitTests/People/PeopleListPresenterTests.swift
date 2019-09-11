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

class PeopleListPresenterTests: PersistenceTestCase {
    var presenter: PeopleListPresenter!

    var resultingBackgroundColor: UIColor?
    var resultingSubtitle: String?

    // To appease ColoredNavViewProtocol
    var color: UIColor?
    var navigationController: UINavigationController?
    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    var expectation = XCTestExpectation(description: "View updated")
    var navbarExpectation = XCTestExpectation(description: "Navbar updated")
    let context = ContextModel(.course, id: "1")

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "View updated")
        navbarExpectation = XCTestExpectation(description: "Navbar updated")
        presenter = PeopleListPresenter(env: env, viewController: self, context: context)
    }

    func testLoadSearchRecipients() {
        SearchRecipient.make(from: APISearchRecipient.make(id: "1", full_name: "John Doe"), canvasContext: context)
        SearchRecipient.make(from: APISearchRecipient.make(id: "2", full_name: "Jane Doe"), canvasContext: context)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(presenter.searchRecipients.count, 2)
        XCTAssertEqual(presenter.searchRecipients.first!.id, "2") // Jane
        XCTAssertEqual(presenter.searchRecipients.last!.id, "1") // John
    }

    func testLoadCourse() {
        let course = Course.make()
        Color.make(canvasContextID: context.canvasContextID, color: UIColor.red)

        presenter.viewIsReady()
        wait(for: [navbarExpectation], timeout: 5)
        XCTAssertEqual(resultingSubtitle, course.name)
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadGroup() {
        let group = Group.make()
        let groupContext = ContextModel(.group, id: group.id)
        Color.make(canvasContextID: groupContext.canvasContextID, color: UIColor.blue)

        presenter = PeopleListPresenter(env: env, viewController: self, context: groupContext)
        presenter.viewIsReady()
        wait(for: [navbarExpectation], timeout: 5)
        XCTAssertEqual(resultingSubtitle, group.name)
        XCTAssertEqual(resultingBackgroundColor, UIColor.blue)
    }

    func testSendsToContextCard() {
        let recipient = SearchRecipient.make()
        presenter.select(recipient: recipient, from: UIViewController())

        let router = env.router as? TestRouter
        XCTAssertEqual(router?.calls.last?.0, .parse("/courses/1/users/1"))
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
