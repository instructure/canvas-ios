//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Combine
@testable import Core
import TestsFoundation

class SubscribersCompletionExtensionsTests: XCTestCase {

    func test_finished() {
        let completion = Subscribers.Completion<MockError>.finished

        XCTAssertEqual(completion.isFinished, true)
        XCTAssertEqual(completion.isFailure, false)
        XCTAssertEqual(completion.error, nil)
    }

    func test_failure() {
        let error = MockError(code: 42, message: "some message")
        let completion = Subscribers.Completion<MockError>.failure(error)

        XCTAssertEqual(completion.isFinished, false)
        XCTAssertEqual(completion.isFailure, true)
        XCTAssertEqual(completion.error, error)
    }
}
