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
    lazy var controller = PageListViewController.create(context: .course("42"), app: .teacher)

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: .init(custom_colors: [
            "course_42": "#000088",
            "group_1": "#facade"
        ]))
        api.mock(controller.course, value: .make(id: "42"))
        api.mock(controller.frontPage, value: .make(front_page: true))
        api.mock(controller.pages, value: [
            .make(html_url: URL(string: "courses/42/pages/dois")!, page_id: "2", title: "Dois"),
            .make(page_id: "3", title: "Trey")
        ])
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        let split = UISplitViewController()
        split.viewControllers = [ nav ]
        split.preferredDisplayMode = .oneBesideSecondary
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#000088")
        XCTAssertEqual(controller.titleSubtitleView.title, "Pages")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssert(router.lastRoutedTo(.parse("/courses/42/pages/answers-page")))

        let createButton = controller.navigationItem.rightBarButtonItem
        _ = createButton?.target?.perform(createButton!.action)
        XCTAssert(router.lastRoutedTo(.parse("courses/42/pages/new")))

        XCTAssertEqual(controller.tableView.numberOfSections, 2)
        let index00 = IndexPath(row: 0, section: 0)
        var cell00 = controller.tableView.cellForRow(at: index00) as? PageListFrontPageCell
        XCTAssertEqual(cell00?.titleLabel.text, "Answers Page")
        let index01 = IndexPath(row: 0, section: 1)
        let cell01 = controller.tableView.cellForRow(at: index01) as? PageListCell
        XCTAssertEqual(cell01?.titleLabel.text, "Dois")
        var cell11 = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? PageListCell
        XCTAssertEqual(cell11?.titleLabel.text, "Trey")

        controller.tableView.selectRow(at: index01, animated: false, scrollPosition: .none)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index01)
        XCTAssert(router.lastRoutedTo(.parse("courses/42/pages/dois")))
        controller.viewWillAppear(false)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)

        NotificationCenter.default.post(name: NSNotification.Name("page-created"), object: nil)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 2)
        NotificationCenter.default.post(name: NSNotification.Name("page-created"), object: nil, userInfo: apiPageToDictionary(page: .make(
            html_url: URL(string: "/courses/42/pages/new-page")!,
            page_id: "1234",
            title: "New Page"
        )))
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 3)
        cell11 = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? PageListCell
        XCTAssertEqual(cell11?.titleLabel.text, "New Page")

        NotificationCenter.default.post(name: NSNotification.Name("page-created"), object: nil, userInfo: apiPageToDictionary(page: .make(
            front_page: true,
            html_url: URL(string: "/courses/42/pages/new-page")!,
            page_id: "1234",
            title: "New Page"
        )))
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        cell00 = controller.tableView.cellForRow(at: index00) as? PageListFrontPageCell
        XCTAssertEqual(cell00?.titleLabel.text, "New Page")

        api.mock(controller.frontPage)
        api.mock(controller.pages, value: [])
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.emptyView.isHidden, false)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testNoCreate() {
        controller.app = .student
        controller.view.layoutIfNeeded()
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)
    }

    func testGroup() {
        controller.context = Context(.group, id: "1")
        api.mock(controller.group, value: .make())
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, UIColor(hexString: "#facade")!.darkenToEnsureContrast(against: .textLightest.variantForLightMode).hexString)
        XCTAssertEqual(controller.titleSubtitleView.title, "Pages")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Group One")
        XCTAssertNotNil(controller.navigationItem.rightBarButtonItem)
    }

    func testPaginatedRefresh() throws {
        // The controller needs to be on screen for this test because the Loading cell needs to appear to trigger the next page load
        window.rootViewController = controller
        drainMainQueue()

        api.mock(controller.frontPage)
        controller.view.layoutIfNeeded()
        api.mock(controller.pages, value: [.make()], response: HTTPURLResponse(next: "/courses/42/pages?page=2"))
        api.mock(GetNextRequest(path: "/courses/42/pages?page=2"), value: [
            APIPage.make(page_id: "12", title: "z next page")
        ])
        let tableView = controller.tableView!
        tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)
        let loading = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? LoadingCell
        XCTAssertNotNil(loading)
        drainMainQueue() // Give some time for the loading cell to trigger the next page load and for the tableview to refresh
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)

        let cell = try XCTUnwrap(
            tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? PageListCell
        )

        XCTAssertEqual(cell.titleLabel.text, "z next page")
    }

    func testFrontPageCellHeightWithFrontPageButNoOtherPages() {
        api.mock(controller.pages, value: [])

        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.tableView(controller.tableView, heightForRowAt: IndexPath(row: 0, section: 0)), UITableView.automaticDimension)
    }

    func apiPageToDictionary(page: APIPage) -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(page)
        return try! JSONSerialization.jsonObject(with: data) as! [String: Any]
    }
}
