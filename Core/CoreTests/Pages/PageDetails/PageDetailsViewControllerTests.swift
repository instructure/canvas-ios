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

class PageDetailsViewControllerTests: CoreTestCase {
    let context = ContextModel(.course, id: "1")
    let pageURL = "test-page"
    let htmlURL = URL(string: "/courses/1/pages/test-page")!

    var viewController: PageDetailsViewController!

    override func setUp() {
        super.setUp()
        viewController = PageDetailsViewController.create(env: environment, context: context, pageURL: pageURL, app: .student)
    }

    func load() {
        XCTAssertNotNil(viewController.view)
    }

    func testViewDidLoad() {
        load()

        XCTAssertEqual(viewController.titleSubtitleView.title, "Page")
        XCTAssertNotNil(viewController.webView?.scrollView.refreshControl)
    }

    func testUpdateNavBar() {
        load()
        _ = UINavigationController(rootViewController: viewController)

        viewController.updateNavBar(subtitle: "My Page", color: .red)
        XCTAssertEqual(viewController.titleSubtitleView.subtitle, "My Page")
        XCTAssertEqual(viewController.navigationController?.navigationBar.barTintColor, .red)
    }

    func testUpdate() {
        let page = Page.make(from: .make(
            body: "<p>This a body</p>",
            html_url: htmlURL,
            title: "My Page",
            url: pageURL
        ))
        load()
        viewController.update()

        XCTAssertEqual(viewController.titleSubtitleView.title, page.title)
    }

    func testAddEditButtonOnce() {
        Page.make(from: .make(
            editing_roles: "teachers,students",
            html_url: htmlURL,
            url: pageURL
        ))
        load()
        _ = UINavigationController(rootViewController: viewController)

        viewController.update()
        XCTAssertEqual(viewController.navigationItem.rightBarButtonItems?.count, 1)

        viewController.update()
        XCTAssertEqual(viewController.navigationItem.rightBarButtonItems?.count, 1)
    }

    func testDoesNotAddEditButton() {
        Page.make(from: .make(
            editing_roles: "teachers",
            html_url: htmlURL,
            url: pageURL
        ))
        load()
        _ = UINavigationController(rootViewController: viewController)

        viewController.update()
        XCTAssertNil(viewController.navigationItem.rightBarButtonItems)
    }

    func testEndsRefreshing() {
        Page.make(from: .make(
            html_url: htmlURL,
            url: pageURL
        ))
        load()
        viewController.webView?.scrollView.refreshControl?.beginRefreshing()

        XCTAssertEqual(viewController.webView?.scrollView.refreshControl?.isRefreshing, true)

        viewController.update()
        XCTAssertEqual(viewController.webView?.scrollView.refreshControl?.isRefreshing, false)
    }

    func testKabobPressed() {
        Page.make(from: .make(
            html_url: htmlURL,
            url: pageURL
        ))

        viewController = PageDetailsViewController.create(env: environment, context: context, pageURL: pageURL, app: .teacher)
        load()

        let barButtonItem = UIBarButtonItem()
        viewController.kabobPressed(barButtonItem)

        wait(for: [router.showExpectation], timeout: 0.1)

        let (shown, vc, _) = router.viewControllerCalls.last!
        XCTAssertEqual(vc, viewController)

        let alert = shown as! UIAlertController
        XCTAssertEqual(alert.actions.count, 3)
        XCTAssertEqual(alert.actions.last?.title, "Cancel")
        XCTAssertEqual(alert.actions.last?.style, .cancel)
    }

    func testKabobDoesNotShowDelete() {
        Page.make(from: .make(
            editing_roles: "teachers",
            html_url: htmlURL,
            url: pageURL
        ))
        load()

        viewController.kabobPressed(UIBarButtonItem())
        wait(for: [router.showExpectation], timeout: 0.1)

        let (shown, _, _) = router.viewControllerCalls.last!
        let alert = shown as! UIAlertController
        XCTAssertEqual(alert.actions.count, 2)
    }

    func testKabobEdit() {
        Page.make(from: .make(
            editing_roles: "teachers,students",
            html_url: htmlURL,
            url: pageURL
        ))
        load()

        viewController.kabobPressed(UIBarButtonItem())
        wait(for: [router.showExpectation], timeout: 0.1)

        let (shown, _, _) = router.viewControllerCalls.last!
        let alert = shown as! UIAlertController
        let action = alert.actions.first! as! AlertAction

        XCTAssertEqual(action.title, "Edit")
        XCTAssertEqual(action.style, .default)

        action.handler?(action)
        wait(for: [router.routeExpectation], timeout: 0.1)
        XCTAssertNotNil(router.lastRoutedTo(htmlURL.appendingPathComponent("edit")))
    }

    func testKabobDelete() {
        Page.make(from: .make(
            html_url: htmlURL,
            url: pageURL
        ))
        viewController = PageDetailsViewController.create(env: environment, context: context, pageURL: pageURL, app: .teacher)
        load()

        viewController.kabobPressed(UIBarButtonItem())
        wait(for: [router.showExpectation], timeout: 0.1)

        let (shown, _, _) = router.viewControllerCalls.last!
        let alert = shown as! UIAlertController

        let action = alert.actions[1] as! AlertAction
        XCTAssertEqual(action.title, "Delete")
        XCTAssertEqual(action.style, .destructive)

        router.resetExpectations()
        action.handler?(action)
        wait(for: [router.showExpectation], timeout: 0.1)

        let (confirm, _, _) = router.viewControllerCalls.last!
        XCTAssertNotEqual(confirm, shown)
        XCTAssert(confirm is UIAlertController)
    }

    func testConfirmDelete() {
        api.mock(DeletePageRequest(context: context, url: pageURL), value: .make())
        Page.make(from: .make(
            html_url: htmlURL,
            url: pageURL
        ))
        viewController = PageDetailsViewController.create(env: environment, context: context, pageURL: pageURL, app: .teacher)
        load()

        viewController.showDeleteConfirmation()
        wait(for: [router.showExpectation], timeout: 0.1)

        let (shown, _, _) = router.viewControllerCalls.last!
        let alert = shown as! UIAlertController

        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions.first?.title, "Cancel")
        XCTAssertEqual(alert.actions.first?.style, .cancel)
        XCTAssertEqual(alert.actions.last?.title, "OK")
        XCTAssertEqual(alert.actions.last?.style, .destructive)

        let action = alert.actions.last as! AlertAction
        action.handler?(action)

        wait(for: [router.popExpectation], timeout: 0.1)
        XCTAssertNil(viewController.presenter.page)
    }
}
