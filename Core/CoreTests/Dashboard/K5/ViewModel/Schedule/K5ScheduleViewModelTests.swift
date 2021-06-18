//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5ScheduleViewModelTests: CoreTestCase {

    func testRefresh() {
        let refreshExpectation = expectation(description: "Refresh finished")
        let testee = K5ScheduleViewModel()
        RunLoop.main.run(until: Date() + 1.1)

        XCTAssertTrue(testee.content.hasSuffix("."))
        testee.refresh {
            refreshExpectation.fulfill()
        }

        wait(for: [refreshExpectation], timeout: 2.1)
        XCTAssertEqual(testee.content, "Binding test")
    }
}
