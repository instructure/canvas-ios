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

class PresenterPageViewLoggerTests: CoreTestCase {

    class MockPresenter: PageViewLoggerPresenterProtocol {
        var internalEnv: AppEnvironment!
        var env: AppEnvironment {
            return internalEnv
        }
        var pageViewEventName: String = "PresenterPageViewLoggerTests"
    }

    var presenter: MockPresenter!
    var mockLogger: MockPageViewLogger = MockPageViewLogger()

    override func setUp() {
        super.setUp()
        environment.pageViewLogger = mockLogger
        presenter = MockPresenter()
        presenter.internalEnv = environment
    }

    func testPresenterLoggingProtocol() {
        presenter.viewDidAppear()
        presenter.viewDidDisappear()
        XCTAssertEqual(mockLogger.eventName, presenter.pageViewEventName)

    }
}
