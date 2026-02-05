//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Combine
@testable import Core
@testable import Student

final class HelloWidgetInteractorLiveTests: StudentTestCase {
    private var testee: HelloWidgetInteractorLive!

    override func setUp() {
        super.setUp()
        api.mock(GetUserProfile(userID: "self"), value: .make(short_name: "Test user"))
        testee = HelloWidgetInteractorLive(env: env)
    }

    func testShortname() {
        let expectation = expectation(description: "User loaded")

        let subscription = testee.getShortName(ignoreCache: false)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { userName in
                XCTAssertEqual("Test user", userName)
            }

        wait(for: [expectation])
        subscription.cancel()
    }

    func testRefresh() {
        let expectation1 = expectation(description: "User loaded")
        let expectation2 = expectation(description: "Username refreshed")
        var iterationCount = 0

        let subscription1 = testee.getShortName(ignoreCache: false)
            .sink(receiveCompletion: { _ in }, receiveValue: { userName in
                iterationCount += 1

                if iterationCount == 1 {
                    XCTAssertEqual("Test user", userName)
                    expectation1.fulfill()
                } else {
                    XCTAssertEqual("Test user 2", userName)
                    expectation2.fulfill()
                }
            })

        wait(for: [expectation1])

        api.mock(GetUserProfile(userID: "self"), value: .make(short_name: "Test user 2"))

        let subscription2 = testee.getShortName(ignoreCache: true)
            .sink { _ in
                expectation2.fulfill()
            } receiveValue: { _ in }

        wait(for: [expectation2])

        subscription1.cancel()
        subscription2.cancel()
    }
}
