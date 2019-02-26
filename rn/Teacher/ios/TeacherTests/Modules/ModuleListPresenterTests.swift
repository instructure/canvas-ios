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

class ModuleListPresenterTests: TeacherTestCase {
    class View: ModuleListViewProtocol {
        var color: UIColor?
        var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()
        var navigationItem: UINavigationItem = UINavigationItem(title: "")
        var navigationController: UINavigationController?

        var onReloadModules: (() -> Void)?
        var onReloadCourse: (() -> Void)?

        func reloadModules() {
            onReloadModules?()
        }

        func reloadCourse() {
            onReloadCourse?()
        }

        func showAlert(title: String?, message: String?) {
        }
    }

    var view: View!
    var presenter: ModuleListPresenter!

    override func setUp() {
        super.setUp()

        view = View()
        presenter = ModuleListPresenter(env: environment, view: view, courseID: "1")
    }

    func testReloadModules() {
        let expectation = XCTestExpectation(description: "modules reloaded")
        view.onReloadModules = {
            if self.presenter.modules.count == 1 {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        Module.make()

        wait(for: [expectation], timeout: 0.1)
    }

    func testReloadCourse() {
        let expectation = XCTestExpectation(description: "modules reloaded")
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
        let first = XCTestExpectation(description: "first load")
        let firstRequest = GetModulesRequest(courseID: "1")
        let firstResponse = [APIModule.make(["name": "Old Name"])]
        api.mock(firstRequest, value: firstResponse, response: nil, error: nil)
        view.onReloadModules = {
            if self.presenter.modules.first?.name == "Old Name" {
                first.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [first], timeout: 1)

        let request = GetModulesRequest(courseID: "1")
        let response = [APIModule.make(["name": "Refreshed"])]
        api.mock(request, value: response, response: nil, error: nil)
        let expectation = XCTestExpectation(description: "modules refreshed")
        view.onReloadModules = {
            if self.presenter.modules.first?.name == "Refreshed" {
                expectation.fulfill()
            }
        }
        presenter.forceRefresh()

        wait(for: [expectation], timeout: 1)
    }
}
