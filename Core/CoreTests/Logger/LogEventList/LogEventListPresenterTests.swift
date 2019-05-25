//
// Copyright (C) 2018-present Instructure, Inc.
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
@testable import Core

class LogEventListPresenterTests: CoreTestCase {
    class View: LogEventListViewProtocol {
        var navigationController: UINavigationController?
        var reloadDataExpectation = XCTestExpectation()

        func reloadData() {
            reloadDataExpectation.fulfill()
        }
    }

    var presenter: LogEventListPresenter!
    let view = View()

    override func setUp() {
        super.setUp()

        presenter = LogEventListPresenter(env: environment, view: view)
    }

    func testApplyFilter() {
        LogEvent.make(type: .log)
        LogEvent.make(type: .error)
        presenter.viewIsReady()
        XCTAssertEqual(presenter.events.count, 2)

        view.reloadDataExpectation = XCTestExpectation()
        presenter.applyFilter(.log)

        wait(for: [view.reloadDataExpectation], timeout: 0.1)
        XCTAssertEqual(presenter.events.count, 1)
        let event = presenter.events[IndexPath(row: 0, section: 0)]
        XCTAssertEqual(event?.type, .log)
    }

    func testClearFilter() {
        LogEvent.make(type: .log)
        LogEvent.make(type: .error)
        presenter.viewIsReady()
        XCTAssertEqual(presenter.events.count, 2)

        // Filter to only show errors
        view.reloadDataExpectation = XCTestExpectation()
        presenter.applyFilter(.log)
        wait(for: [view.reloadDataExpectation], timeout: 0.1)
        XCTAssertEqual(presenter.events.count, 1)

        // Apply filter back to nil
        view.reloadDataExpectation = XCTestExpectation()
        presenter.applyFilter(nil)
        wait(for: [view.reloadDataExpectation], timeout: 0.1)
        XCTAssertEqual(presenter.events.count, 2)
    }
}
