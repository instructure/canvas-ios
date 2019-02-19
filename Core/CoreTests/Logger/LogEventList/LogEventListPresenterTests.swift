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

    func testNumberOfEventsZero() {
        presenter.viewIsReady()
        XCTAssertEqual(presenter.numberOfEvents, 0)
    }

    func testNumberOfEventsNonZero() {
        LogEvent.make()
        LogEvent.make()
        presenter.viewIsReady()
        XCTAssertEqual(presenter.numberOfEvents, 2)
    }

    func testLogEventForIndexPath() {
        let expectedOne = LogEvent.make(["timestamp": Date().addDays(-1)])
        let expectedTwo = LogEvent.make(["timestamp": Date().addDays(-2)])
        presenter.viewIsReady()
        let one = presenter.logEvent(for: IndexPath(row: 0, section: 0))
        let two = presenter.logEvent(for: IndexPath(row: 1, section: 0))

        XCTAssertEqual(expectedOne.timestamp, one?.timestamp)
        XCTAssertEqual(expectedTwo.timestamp, two?.timestamp)
    }

    func testApplyFilter() {
        LogEvent.make(["typeRaw": LoggableType.log.rawValue])
        LogEvent.make(["typeRaw": LoggableType.error.rawValue])
        presenter.viewIsReady()
        XCTAssertEqual(presenter.numberOfEvents, 2)

        view.reloadDataExpectation = XCTestExpectation()
        presenter.applyFilter(.type(.log))

        wait(for: [view.reloadDataExpectation], timeout: 0.1)
        XCTAssertEqual(presenter.numberOfEvents, 1)
        let event = presenter.logEvent(for: IndexPath(row: 0, section: 0))
        XCTAssertEqual(event?.type, .log)
    }

    func testClearFilter() {
        LogEvent.make(["typeRaw": LoggableType.log.rawValue])
        LogEvent.make(["typeRaw": LoggableType.error.rawValue])
        presenter.viewIsReady()
        XCTAssertEqual(presenter.numberOfEvents, 2)

        // Filter to only show errors
        view.reloadDataExpectation = XCTestExpectation()
        presenter.applyFilter(.type(.log))
        wait(for: [view.reloadDataExpectation], timeout: 0.1)
        XCTAssertEqual(presenter.numberOfEvents, 1)

        // Apply filter back to .all
        view.reloadDataExpectation = XCTestExpectation()
        presenter.applyFilter(.all)
        wait(for: [view.reloadDataExpectation], timeout: 0.1)
        XCTAssertEqual(presenter.numberOfEvents, 2)
    }
}
