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

final class APIAnalyticsConsentTests: XCTestCase {

    // MARK: - isValid

    func test_isValid_whenDataIsPresent_shouldBeTrue() {
        let testee = APIAnalyticsConsent(data: .init(mobile_consent: true), message: nil)
        XCTAssertEqual(testee.isValid, true)
    }

    func test_isValid_whenMessageIsNoData_shouldBeTrue() {
        let testee = APIAnalyticsConsent(data: nil, message: APIAnalyticsConsent.noDataMessage)
        XCTAssertEqual(testee.isValid, true)
    }

    func test_isValid_whenDataIsNilAndMessageIsNil_shouldBeFalse() {
        let testee = APIAnalyticsConsent(data: nil, message: nil)
        XCTAssertEqual(testee.isValid, false)
    }

    func test_isValid_whenDataIsNilAndMessageIsUnexpected_shouldBeFalse() {
        let testee = APIAnalyticsConsent(data: nil, message: "some unexpected message")
        XCTAssertEqual(testee.isValid, false)
    }
}
