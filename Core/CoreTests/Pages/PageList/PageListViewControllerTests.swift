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

class PageListViewControllerTests: CoreTestCase {
    var viewController: PageListViewController!
    let context = ContextModel(.course, id: "1")

    override func setUp() {
        super.setUp()
        viewController = PageListViewController.create(env: environment, context: context, appTraitCollection: nil, app: .student)
    }

    func testItAddsThePlusButtonInTeacherApp() {
        viewController = PageListViewController.create(env: environment, context: context, appTraitCollection: nil, app: .teacher)
        viewController.update(isLoading: false)
        XCTAssertEqual(viewController.navigationItem.rightBarButtonItems?.count, 1)
    }

    func testItDoesNotAddThePlusButtonInStudentCourse() {
        viewController = PageListViewController.create(env: environment, context: context, appTraitCollection: nil, app: .student)
        viewController.update(isLoading: false)
        XCTAssertNil(viewController.navigationItem.rightBarButtonItems)
    }

    func testItDoesAddThePlusButtonInStudentGroup() {
        viewController = PageListViewController.create(env: environment, context: ContextModel(.group, id: "1"), appTraitCollection: nil, app: .student)
        viewController.update(isLoading: false)
        XCTAssertEqual(viewController.navigationItem.rightBarButtonItems?.count, 1)
    }

    func load() {
        viewController.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        viewController.view.layoutIfNeeded()
        viewController.viewDidLoad()
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }

    func testRender() {
        viewController = PageListViewController.create(env: environment, context: context, appTraitCollection: nil, app: .student)
        environment.mockStore = false

        api.mock(viewController.presenter!.course!, value: APICourse.make())
        api.mock(viewController.presenter!.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        let a = APIPage.make(html_url: URL(string: "/courses/1/pages/one")!, page_id: ID(1), title: "A")
        api.mock(viewController.presenter!.pages.all!, value: [a])
        let frontPage = APIPage.make(body: "hello front page", front_page: true, html_url: URL(string: "/courses/3/pages/three")!, page_id: ID(3), title: "frontpage")
        api.mock(viewController.presenter!.pages.frontPage!, value: frontPage)

        load()

        XCTAssertEqual(viewController.presenter!.pages.all?.count, 1)

        let cell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PageListCell
        XCTAssertEqual(cell?.titleLabel?.text, "A")
        let expectedDate = PageListCell.dateFormatter.string(from: a.updated_at)
        XCTAssertEqual(cell?.dateLabel?.text, expectedDate)
        XCTAssertEqual(cell?.accessIconView?.icon, UIImage.icon(.document, .line))
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo(.parse("/courses/1/pages/one")))

        XCTAssertEqual(viewController.frontPageTitleLabel.text, frontPage.title)
        XCTAssertEqual(viewController.frontPageTitleLabel.isHidden, false)

        viewController.frontPageViewButton.sendActions(for: .touchUpInside)
        XCTAssert(router.lastRoutedTo(.parse("/courses/3/pages/three")))
    }
}
