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
@testable import Teacher
import TestsFoundation
@testable import Core
import CoreData
import SafariServices

class ModuleListPresenterTests: TeacherTestCase {
    class View: ModuleListViewProtocol {
        var color: UIColor?
        var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()
        var navigationItem: UINavigationItem = UINavigationItem(title: "")
        var navigationController: UINavigationController?

        var onReloadModules: (() -> Void)?
        var onReloadCourse: (() -> Void)?
        var refreshing = false

        func reloadModules() {
            onReloadModules?()
        }

        func reloadCourse() {
            onReloadCourse?()
        }

        func showAlert(title: String?, message: String?) {
        }

        var onShowPending: (() -> Void)?
        func showPending() {
            refreshing = true
            onShowPending?()
        }

        var onHidePending: (() -> Void)?
        func hidePending() {
            refreshing = false
            onHidePending?()
        }

        var onScrollToIndexPath: ((IndexPath) -> Void)?
        func scrollToRow(at indexPath: IndexPath) {
            onScrollToIndexPath?(indexPath)
        }

        var reloadedSections: [Int] = []
        func reloadModuleInSection(_ section: Int) {
            reloadedSections.append(section)
        }
    }

    class MockViewController: UIViewController {
        var presented: UIViewController?
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            presented = viewControllerToPresent
        }
    }

    var view: View!
    var presenter: ModuleListPresenter!
    let courseID = "1"

    override func setUp() {
        super.setUp()

        view = View()
        presenter = ModuleListPresenter(env: environment, view: view, courseID: courseID)
    }

    func testReloadModules() {
        let reloaded = expectation(description: "reloaded")
        reloaded.assertForOverFulfill = false
        view.onReloadModules = {
            if self.presenter?.modules.count == 1 {
                reloaded.fulfill()
            }
        }
        presenter.viewIsReady()
        Module.make(forCourse: courseID)

        wait(for: [reloaded], timeout: 9)
    }

    func testModulesOrder() {
        let courseID = "1"
        Module.make(from: .make(
            id: "1",
            name: "Module 1",
            position: 1,
            items: [ .make(module_id: "1") ]
        ), forCourse: courseID)
        Module.make(from: .make(
            id: "2",
            name: "Module 2",
            position: 2,
            items: [ .make(module_id: "2") ]
        ), forCourse: courseID)
        Module.make(from: .make(
            id: "3",
            name: "Module 3",
            position: 3,
            items: [ .make(module_id: "3") ]
        ), forCourse: courseID)
        let reloaded = expectation(description: "reloaded")
        reloaded.assertForOverFulfill = false
        view.onReloadModules = {
            if self.presenter.modules.count == 3 {
                reloaded.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [reloaded], timeout: 9)

        XCTAssertEqual(presenter.modules[0]?.name, "Module 1")
        XCTAssertEqual(presenter.modules[1]?.name, "Module 2")
        XCTAssertEqual(presenter.modules[2]?.name, "Module 3")
    }

    func testModuleItemsOrder() {
        Module.make(from: .make(
            items: [
                .make(id: "1", title: "one"),
                .make(id: "2", title: "two"),
                .make(id: "3", title: "three"),
            ]
        ))
        let items = presenter.modules[0]?.items
        XCTAssertEqual(items?.count, 3)
        XCTAssertEqual(items?[0].title, "one")
        XCTAssertEqual(items?[1].title, "two")
        XCTAssertEqual(items?[2].title, "three")
    }

    func testReloadCourse() {
        let reloaded = expectation(description: "reloaded")
        reloaded.assertForOverFulfill = false
        view.onReloadCourse = {
            if self.presenter.course != nil {
                reloaded.fulfill()
            }
        }
        presenter.viewIsReady()
        Course.make(from: .make(id: "1"))

        wait(for: [reloaded], timeout: 9)
    }

    func testReloadCourseColor() {
        let color = UIColor.red
        let reloaded = expectation(description: "course reloaded")
        reloaded.assertForOverFulfill = false
        view.onReloadCourse = {
            if self.presenter.course?.color == color {
                reloaded.fulfill()
            }
        }
        presenter.viewIsReady()
        Course.make(from: .make(id: "1"))
        ContextColor.make(canvasContextID: "course_1", color: color)

        wait(for: [reloaded], timeout: 9)
    }

    func testRefreshCourseColors() {
        let request = GetCustomColorsRequest()
        let response = APICustomColors(custom_colors: ["course_1": "#000000"])
        api.mock(request, value: response, response: nil, error: nil)
        let reloaded = expectation(description: "color refreshed")
        reloaded.assertForOverFulfill = false
        view.onReloadCourse = {
            if self.presenter.course?.color.hexString == "#000000" {
                reloaded.fulfill()
            }
        }
        presenter.viewIsReady()
        Course.make(from: .make(id: "1"))

        wait(for: [reloaded], timeout: 9)
    }

    func testForceRefresh() {
        let first = expectation(description: "first load")
        first.assertForOverFulfill = false
        let firstRequest = GetModulesRequest(courseID: "1")
        let firstResponse = [APIModule.make(name: "Old Name")]
        api.mock(firstRequest, value: firstResponse, response: nil, error: nil)
        view.onReloadModules = {
            if self.presenter.modules.count == 1, self.presenter.modules[0]?.name == "Old Name" {
                first.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [first], timeout: 9)

        let request = GetModulesRequest(courseID: "1")
        let response = [APIModule.make(name: "Refreshed")]
        api.mock(request, value: response, response: nil, error: nil)
        let refreshed = expectation(description: "modules refreshed")
        refreshed.assertForOverFulfill = false
        let pending = expectation(description: "start pending")
        let stopPending = expectation(description: "stop pending")
        view.onShowPending = pending.fulfill
        view.onHidePending = stopPending.fulfill
        view.onReloadModules = {
            if self.presenter.modules.count == 1, self.presenter.modules[0]?.name == "Refreshed" {
                refreshed.fulfill()
            }
        }
        presenter.forceRefresh()
        wait(for: [pending, refreshed, stopPending], timeout: 9)
    }

    func testScrollsToModule() {
        let page1Request = GetModulesRequest(courseID: "1")
        let page1Response = [
            APIModule.make(
                id: "1",
                position: 1
            ),
        ]
        let prev = "https://cgnuonline-eniversity.edu/api/v1/courses/1/modules"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/courses/1/modules?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/courses/1/modules?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let urlResponse = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        api.mock(page1Request, value: page1Response, response: urlResponse, error: nil)
        let page2Request = page1Request.getNext(from: urlResponse)!
        let page2Response = [
            APIModule.make(
                id: "2",
                position: 2
            ),
        ]
        api.mock(page2Request, value: page2Response, response: nil, error: nil)
        let scrolled = expectation(description: "scrolled to module")
        scrolled.assertForOverFulfill = false
        view.onScrollToIndexPath = { indexPath in
            if indexPath == IndexPath(row: 0, section: 1) {
                scrolled.fulfill()
            }
        }
        let presenter = ModuleListPresenter(env: environment, view: view, courseID: courseID, moduleID: "2")
        presenter.viewIsReady()
        wait(for: [scrolled], timeout: 9)
        XCTAssertTrue(presenter.isSectionExpanded(1))
    }

    func testTappedSection() {
        let loaded = expectation(description: "loaded module")
        loaded.assertForOverFulfill = false
        view.onReloadModules = {
            if self.presenter.modules.count == 1 {
                loaded.fulfill()
            }
        }
        presenter.viewIsReady()
        Module.make(forCourse: courseID)
        wait(for: [loaded], timeout: 9)
        XCTAssertTrue(presenter.isSectionExpanded(0))

        // collapse
        presenter.tappedSection(0)
        XCTAssertTrue(view.reloadedSections.contains(0))
        XCTAssertFalse(presenter.isSectionExpanded(0))

        // expand
        presenter.tappedSection(0)
        XCTAssertTrue(view.reloadedSections.contains(0))
        XCTAssertEqual(view.reloadedSections.count, 2)
        XCTAssertTrue(presenter.isSectionExpanded(0))
    }

    func testShowItem() {
        let url = URL(string: "/courses/1/assignments/2")!
        let item = ModuleItem.make(from: .make(url: url))
        presenter.showItem(item, from: MockViewController())
        XCTAssertTrue(router.lastRoutedTo(.course("1", assignment: "2")))
    }
}
