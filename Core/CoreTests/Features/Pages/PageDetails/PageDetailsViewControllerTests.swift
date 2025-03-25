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
import WebKit
import TestsFoundation

class PageDetailsViewControllerTests: CoreTestCase {
    lazy var controller = PageDetailsViewController
        .create(context: context, pageURL: pageURL, app: .student, env: environment)

    let context = Context(.course, id: "1")
    var htmlURL = URL(string: "/courses/1/pages/test-page")!
    var pageURL = "test-page"

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: .init(custom_colors: [
            "course_1": "#008800",
            "group_1": "#000088"
        ]))
        api.mock(GetCourse(courseID: "1"), value: .make())
        api.mock(GetGroup(groupID: "1"), value: .make())
        api.mock(GetPageRequest(context: context, url: pageURL), value: .make(
            editing_roles: "teachers,students",
            html_url: htmlURL,
            title: "Test Page",
            url: pageURL
        ))
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        window.rootViewController = nav
        waitUntil(shouldFail: true) {
            controller.view.superview != nil
        }

        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#008800")
        XCTAssertEqual(controller.titleSubtitleView.title, "Test Page")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.count, 1)

        let optionsButton = controller.navigationItem.rightBarButtonItem
        _ = optionsButton?.target?.perform(optionsButton!.action, with: [optionsButton])
        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.actions.count, 2)
        XCTAssertEqual(alert?.actions.last?.title, "Cancel")
        XCTAssertEqual(alert?.actions.last?.style, .cancel)
        XCTAssertEqual(alert?.actions.first?.title, "Edit")
        (alert?.actions.first as? AlertAction)?.handler?(AlertAction())
        XCTAssertNotNil(router.lastRoutedTo(htmlURL.appendingPathComponent("edit")))

        api.mock(DeletePageRequest(context: context, url: pageURL), error: NSError.internalError())
        controller.app = .teacher
        _ = optionsButton?.target?.perform(optionsButton!.action, with: [optionsButton])
        let deleteAction = (router.presented as? UIAlertController)?.actions[1]
        XCTAssertEqual(deleteAction?.title, "Delete")
        XCTAssertEqual(deleteAction?.style, .destructive)
        (deleteAction as? AlertAction)?.handler?(AlertAction())
        let confirmAction = (router.presented as? UIAlertController)?.actions.last
        (confirmAction as? AlertAction)?.handler?(AlertAction())
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")

        router.viewControllerCalls = []
        api.mock(DeletePageRequest(context: context, url: pageURL))
        (confirmAction as? AlertAction)?.handler?(AlertAction())
        XCTAssertNil(router.presented)

        api.mock(GetPageRequest(context: context, url: pageURL), value: .make(
            html_url: htmlURL,
            title: "Refreshed",
            url: pageURL
        ))
        controller.app = .student
        controller.webView.scrollView.refreshControl?.beginRefreshing()
        controller.webView.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.webView.scrollView.refreshControl?.isRefreshing, true)
        RunLoop.main.run(until: Date() + 1.5)
        XCTAssertEqual(controller.webView.scrollView.refreshControl?.isRefreshing, false)
        XCTAssertEqual(controller.titleSubtitleView.title, "Refreshed")
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)
    }

    func testGroup() {
        controller.context = Context(.group, id: "1")
        api.mock(GetPageRequest(context: controller.context, url: pageURL), value: .make(
            html_url: URL(string: "/groups/1/pages/test-page")!,
            title: "Test Page",
            url: pageURL
        ))
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#000088")
        XCTAssertEqual(controller.titleSubtitleView.title, "Test Page")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Group One")
    }

    func testFrontPage() {
        htmlURL = URL(string: "/courses/1/pages/front_page")!
        pageURL = "front_page"
        controller = PageDetailsViewController
            .create(context: context, pageURL: pageURL, app: .student, env: environment)
        api.mock(GetFrontPageRequest(context: context), value: .make(
            front_page: true,
            html_url: htmlURL,
            title: "Front Page"
        ))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.titleSubtitleView.title, "Front Page")
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)
    }
}
