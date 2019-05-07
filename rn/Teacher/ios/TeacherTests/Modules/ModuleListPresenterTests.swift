//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        let expectation = XCTestExpectation(description: "reloaded")
        view.onReloadModules = {
            if self.presenter?.modules.count == 1 {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        Module.make(["courseID": courseID])

        wait(for: [expectation], timeout: 0.1)
    }

    func testModulesOrder() {
        let courseID = "1"
        Module.make([
            "position": 1,
            "name": "Module 1",
            "courseID": courseID,
            "id": "1",
            "itemsRaw": NSOrderedSet(array: [ModuleItem.make(["moduleID": "1"])]),
        ])
        Module.make([
            "position": 2,
            "name": "Module 2",
            "courseID": courseID,
            "id": "2",
            "itemsRaw": NSOrderedSet(array: [ModuleItem.make(["moduleID": "2"])]),
        ])
        Module.make([
            "position": 3,
            "name": "Module 3",
            "courseID": courseID,
            "id": "3",
            "itemsRaw": NSOrderedSet(array: [ModuleItem.make(["moduleID": "3"])]),
        ])
        let expectation = XCTestExpectation(description: "reloaded")
        view.onReloadModules = {
            if self.presenter.modules.count == 3 {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(presenter.modules[0]?.name, "Module 1")
        XCTAssertEqual(presenter.modules[1]?.name, "Module 2")
        XCTAssertEqual(presenter.modules[2]?.name, "Module 3")
    }

    func testModuleItemsOrder() {
        Module.make([
            "itemsRaw": NSOrderedSet(array: [
                ModuleItem.make(["title": "one"]),
                ModuleItem.make(["title": "two"]),
                ModuleItem.make(["title": "three"])
            ]),
        ])
        let expectation = XCTestExpectation(description: "reloaded")
        view.onReloadModules = {
            if self.presenter.modules.first?.items.count == 3 {
                expectation.fulfill()
            }
        }

        let items = self.presenter.modules[0]?.items
        XCTAssertEqual(items?.count, 3)
        XCTAssertEqual(items?[0].title, "one")
        XCTAssertEqual(items?[1].title, "two")
        XCTAssertEqual(items?[2].title, "three")
    }

    func testReloadCourse() {
        let expectation = XCTestExpectation(description: "reloaded")
        view.onReloadCourse = {
            if self.presenter.course != nil {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        Course.make(["id": "1"])

        wait(for: [expectation], timeout: 0.1)
    }

    func testReloadCourseColor() {
        let color = UIColor.red
        let expectation = XCTestExpectation(description: "course reloaded")
        view.onReloadCourse = {
            if self.presenter.course?.color == color {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        Course.make(["id": "1"])
        Color.make(["canvasContextID": "course_1", "color": color])

        wait(for: [expectation], timeout: 0.1)
    }

    func testRefreshCourseColors() {
        let request = GetCustomColorsRequest()
        let response = APICustomColors(custom_colors: ["course_1": "#000000"])
        api.mock(request, value: response, response: nil, error: nil)
        let expectation = XCTestExpectation(description: "color refreshed")
        view.onReloadCourse = {
            if self.presenter.course?.color.hexString == "#000000" {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        Course.make(["id": "1"])

        wait(for: [expectation], timeout: 0.5)
    }

    func testForceRefresh() {
        presenter.viewIsReady()
        let first = XCTestExpectation(description: "first load")
        let firstRequest = GetModulesRequest(courseID: "1")
        let firstResponse = [APIModule.make(["name": "Old Name"])]
        api.mock(firstRequest, value: firstResponse, response: nil, error: nil)
        view.onReloadModules = {
            if self.presenter.modules.count == 1, self.presenter.modules[0]?.name == "Old Name" {
                first.fulfill()
            }
        }
        wait(for: [first], timeout: 9)

        let request = GetModulesRequest(courseID: "1")
        let response = [APIModule.make(["name": "Refreshed"])]
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
            APIModule.make([
                "id": "1",
                "courseID": courseID,
                "position": 1
            ])
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
            APIModule.make([
                "id": "2",
                "courseID": courseID,
                "position": 2
            ])
        ]
        api.mock(page2Request, value: page2Response, response: nil, error: nil)
        let expectation = XCTestExpectation(description: "scrolled to module")
        view.onScrollToIndexPath = { indexPath in
            if indexPath == IndexPath(row: 0, section: 1) {
                expectation.fulfill()
            }
        }
        let presenter = ModuleListPresenter(env: environment, view: view, courseID: courseID, moduleID: "2")
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(presenter.isSectionExpanded(1))
    }

    func testGetsNextPage() {
        let page1Request = GetModulesRequest(courseID: "1")
        let page1Response = [
            APIModule.make([
                "id": "1",
                "courseID": courseID,
                "position": 1
            ])
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
            APIModule.make([
                "id": "2",
                "courseID": courseID,
                "position": 2
            ])
        ]
        api.mock(page2Request, value: page2Response, response: nil, error: nil)
        var expectation = XCTestExpectation(description: "first page")
        view.onReloadModules = {
            if self.presenter.modules.count == 1 {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1.0)
        expectation = XCTestExpectation(description: "second page")
        view.onReloadModules = {
            if self.presenter.modules.count == 2 {
                expectation.fulfill()
            }
        }
        presenter.getNextPage()
        wait(for: [expectation], timeout: 1.0)
    }

    func testTappedSection() {
        let expectation = XCTestExpectation(description: "loaded module")
        view.onReloadModules = {
            if self.presenter.modules.count == 1 {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        Module.make(["courseID": courseID])
        wait(for: [expectation], timeout: 0.1)
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

    func testShowItemExternalTool() {
        let url = URL(string: "https://canvas.instructure.com/courses/1/external_tools/1?sessionless_launch=YES")!
        let item = ModuleItem.make(["typeRaw": ModuleItemType.externalTool("1", url).data])
        let vc = MockViewController()
        presenter.showItem(item, from: vc)
        XCTAssertNotNil(vc.presented as? SFSafariViewController)
    }

    func testShowItemExternalURL() {
        let url = URL(string: "https://google.com")!
        let item = ModuleItem.make(["typeRaw": ModuleItemType.externalURL(url).data])
        let vc = MockViewController()
        presenter.showItem(item, from: vc)
        XCTAssertNotNil(vc.presented as? SFSafariViewController)
    }

    func testShowItem() {
        let url = URL(string: "/courses/1/assignments/2")!
        let item = ModuleItem.make(["url": url])
        presenter.showItem(item, from: MockViewController())
        XCTAssertTrue(router.lastRoutedTo(.course("1", assignment: "2")))
    }
}
