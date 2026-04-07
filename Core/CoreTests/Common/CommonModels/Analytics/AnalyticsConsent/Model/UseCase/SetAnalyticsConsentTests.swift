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

import XCTest
@testable import Core
import TestsFoundation

final class SetAnalyticsConsentTests: XCTestCase {

    // MARK: - cacheKey

    func test_cacheKey_shouldBeNil() {
        let testee = SetAnalyticsConsent(app: .student, value: true)
        XCTAssertEqual(testee.cacheKey, nil)
    }

    // MARK: - request

    func test_request_shouldUseAppConsentNamespaceAndValue() {
        var testee = SetAnalyticsConsent(app: .student, value: true)
        XCTAssertEqual(testee.request.namespace, .student)
        XCTAssertEqual(testee.request.value, true)

        testee = SetAnalyticsConsent(app: .horizon, value: false)
        XCTAssertEqual(testee.request.namespace, .student)
        XCTAssertEqual(testee.request.value, false)

        testee = SetAnalyticsConsent(app: .teacher, value: true)
        XCTAssertEqual(testee.request.namespace, .teacher)
        XCTAssertEqual(testee.request.value, true)

        testee = SetAnalyticsConsent(app: .parent, value: false)
        XCTAssertEqual(testee.request.namespace, .parent)
        XCTAssertEqual(testee.request.value, false)
    }
}
