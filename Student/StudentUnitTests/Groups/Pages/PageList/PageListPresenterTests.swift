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
@testable import Student
import Core
import TestsFoundation

class PageListPresenterTests: PersistenceTestCase {

    var resultingError: NSError?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: PageListPresenter!

    let update = XCTestExpectation(description: "presenter updated")
    var onUpdateNavBar: ((String?, UIColor?) -> Void)?

    var color: UIColor?
    var navigationController: UINavigationController?
    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    override func setUp() {
        super.setUp()
        presenter = PageListPresenter(env: env, view: self, context: ContextModel(.course, id: "42"))
    }

    func testLoadCourse() {
        XCTAssertNil(resultingSubtitle)
        XCTAssertNil(resultingBackgroundColor)

        let c = Course.make(from: .make(id: "42"), in: databaseClient)
        Color.make(canvasContextID: c.canvasContextID, color: UIColor.red)

        let expectation = self.expectation(description: "navbar")
        expectation.assertForOverFulfill = false
        onUpdateNavBar = {
            if $0 == c.name && $1 == c.color { expectation.fulfill() }
        }
        presenter.viewIsReady()

        wait(for: [expectation], timeout: 5)
    }

    func testLoadPages() {
        Page.make(from: .make(title: "Answers Page"))
        presenter.viewIsReady()
        XCTAssertEqual(presenter.pages.first?.title, "Answers Page")
    }

    func testLoadFrontPage() {
        Page.make(from: .make(front_page: true, title: "Front Page"))
        presenter.viewIsReady()
        XCTAssertEqual(presenter.frontPage.first?.title, "Front Page")
        XCTAssertEqual(presenter.frontPage.first?.isFrontPage, true)
    }

    func testSelect() {
        let page = Page.make()
        let router = env.router as? TestRouter
        XCTAssertNoThrow(presenter.select(page, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(page.htmlURL))
    }
}

extension PageListPresenterTests: PageListViewProtocol {
    func update(isLoading: Bool) {
        update.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingBackgroundColor = color
        resultingSubtitle = subtitle
        onUpdateNavBar?(subtitle, color)
    }
}
