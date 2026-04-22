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

final class GetAnalyticsConsentRequestTests: XCTestCase {

    // MARK: - path

    func test_path() {
        let testee = GetAnalyticsConsentRequest(namespace: .student)
        XCTAssertEqual(testee.path, "users/self/custom_data/data_sync")
    }

    // MARK: - query

    func test_query_shouldIncludeNamespace() {
        var testee = GetAnalyticsConsentRequest(namespace: .student)
        XCTAssertEqual(testee.query, [.value("ns", "MOBILE_CANVAS_STUDENT_COOKIE_CONSENT")])

        testee = GetAnalyticsConsentRequest(namespace: .teacher)
        XCTAssertEqual(testee.query, [.value("ns", "MOBILE_CANVAS_TEACHER_COOKIE_CONSENT")])

        testee = GetAnalyticsConsentRequest(namespace: .parent)
        XCTAssertEqual(testee.query, [.value("ns", "MOBILE_CANVAS_PARENT_COOKIE_CONSENT")])
    }
}
