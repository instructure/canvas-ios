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

final class TrackingPolicyTests: XCTestCase {

    // MARK: - init(usageMetrics:)

    func test_init_withKnownValues_shouldReturnMatchingCase() {
        // WHEN track_usage
        var testee = TrackingPolicy(usageMetrics: "track_usage")
        // THEN
        XCTAssertEqual(testee, .trackingEnabled)

        // WHEN no_track_usage
        testee = TrackingPolicy(usageMetrics: "no_track_usage")
        // THEN
        XCTAssertEqual(testee, .trackingDisabled)

        // WHEN ask_for_consent
        testee = TrackingPolicy(usageMetrics: "ask_for_consent")
        // THEN
        XCTAssertEqual(testee, .askForConsent)
    }

    func test_init_whenNil_shouldReturnNil() {
        XCTAssertEqual(TrackingPolicy(usageMetrics: nil), nil)
    }

    func test_init_whenUnknown_shouldFallbackToTrackingDisabled() {
        XCTAssertEqual(TrackingPolicy(usageMetrics: "some_unknown_value"), .trackingDisabled)
    }
}
