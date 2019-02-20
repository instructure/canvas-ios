//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
@testable import Teacher
import TestsFoundation
@testable import Core

class ModuleListPresenterTests: TeacherTestCase {
    class View: ModuleListViewProtocol {
        var onReloadModules: (() -> Void)?
        func reloadModules() {
            onReloadModules?()
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
}
