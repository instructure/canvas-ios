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

import XCTest
@testable import Core
import TestsFoundation

class PageDetailsPresenterTests: CoreTestCase {
    var presenter: PageDetailsPresenter!
    let context = ContextModel(.course, id: "1")
    let pageURL = "page-test"

    var updateExpectation: XCTestExpectation!
    var dismissExpectation: XCTestExpectation!
    var navExpectation: XCTestExpectation!

    var resultingSubtitle: String?
    var resultingColor: UIColor?

    var color: UIColor?
    var navigationController: UINavigationController?
    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    override func setUp() {
        super.setUp()
        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .student)
        updateExpectation = XCTestExpectation(description: "Update")
        dismissExpectation = XCTestExpectation(description: "Dismiss")
        navExpectation = XCTestExpectation(description: "Nav")
    }

    func testUseCasesSetup() {
        XCTAssertEqual(presenter.courses.useCase.courseID, context.id)
        XCTAssertEqual(presenter.groups.useCase.groupID, context.id)
        XCTAssertEqual(presenter.pages.useCase.context.canvasContextID, context.canvasContextID)
        XCTAssertEqual(presenter.pages.useCase.url, presenter.pageURL)
    }

    func testLoadCourseColor() {
        Course.make()
        ContextColor.make()

        presenter.colors.eventHandler()
        wait(for: [navExpectation], timeout: 0.1)

        XCTAssertEqual(resultingColor, UIColor.red)
    }

    func testLoadGroupColor() {
        let group = Group.make()
        ContextColor.make(canvasContextID: group.canvasContextID, color: UIColor.blue)

        presenter.colors.eventHandler()
        wait(for: [navExpectation], timeout: 0.1)

        XCTAssertEqual(resultingColor, UIColor.blue)
    }

    func testLoadCourse() {
        let course = Course.make()

        presenter.courses.eventHandler()
        wait(for: [navExpectation], timeout: 0.1)

        XCTAssertEqual(resultingSubtitle, course.name)
    }

    func testLoadGroup() {
        let group = Group.make()

        presenter.groups.eventHandler()
        wait(for: [navExpectation], timeout: 0.1)

        XCTAssertEqual(resultingSubtitle, group.name)
    }

    func testLoadPage() {
        Page.make(from: .make(url: pageURL))

        presenter.pages.eventHandler()
        wait(for: [updateExpectation], timeout: 0.1)

        XCTAssertNotNil(presenter.page)
        XCTAssertEqual(presenter.page?.url, pageURL)
    }

    func testViewIsReadyCourse() {
        presenter.viewIsReady()

        let colorsStore = presenter.colors as! TestStore
        let coursesStore = presenter.courses as! TestStore
        let pagesStore = presenter.pages as! TestStore

        wait(for: [colorsStore.refreshExpectation, coursesStore.refreshExpectation, pagesStore.refreshExpectation], timeout: 1)
    }
}

extension PageDetailsPresenterTests: PageDetailsViewProtocol {
    public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        dismissExpectation.fulfill()
    }

    public func update() {
        updateExpectation.fulfill()
    }

    public func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingSubtitle = subtitle
        resultingColor = color
        navExpectation.fulfill()
    }

    public func showAlert(title: String?, message: String?) {

    }

    public func showError(_ error: Error) {

    }
}
