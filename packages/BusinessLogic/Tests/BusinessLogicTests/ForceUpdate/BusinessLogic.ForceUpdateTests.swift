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

import Testing
@testable import BusinessLogic

struct BusinessLogicForceUpdateTests {
    private let testee = BusinessLogic.ForceUpdateLive()

    @Test
    func shouldForceUpdate_returnsFalseWhenAppVersionIsNil() {
        let shouldForceUpdate = testee.shouldForceUpdate(
            appVersion: nil,
            systemVersion: "18.0",
            minimumSystemVersion: "16.0",
            belowAppVersion: "5.0.0"
        )
        #expect(!shouldForceUpdate)
    }

    @Test
    func shouldForceUpdate_returnsTrueWhenAppVersionBelowThresholdAndSystemMeetsMinimum() {
        let shouldForceUpdate = testee.shouldForceUpdate(
            appVersion: "4.9.0",
            systemVersion: "18.0",
            minimumSystemVersion: "16.0",
            belowAppVersion: "5.0.0"
        )
        #expect(shouldForceUpdate)
    }

    @Test
    func shouldForceUpdate_returnsFalseWhenAppVersionEqualsThreshold() {
        let shouldForceUpdate = testee.shouldForceUpdate(
            appVersion: "5.0.0",
            systemVersion: "18.0",
            minimumSystemVersion: "16.0",
            belowAppVersion: "5.0.0"
        )
        #expect(!shouldForceUpdate)
    }

    @Test
    func shouldForceUpdate_returnsFalseWhenAppVersionAboveThreshold() {
        let shouldForceUpdate = testee.shouldForceUpdate(
            appVersion: "6.0.0",
            systemVersion: "18.0",
            minimumSystemVersion: "16.0",
            belowAppVersion: "5.0.0"
        )
        #expect(!shouldForceUpdate)
    }

    @Test
    func shouldForceUpdate_returnsFalseWhenSystemVersionBelowMinimum() {
        let shouldForceUpdate = testee.shouldForceUpdate(
            appVersion: "4.9.0",
            systemVersion: "15.0",
            minimumSystemVersion: "16.0",
            belowAppVersion: "5.0.0"
        )
        #expect(!shouldForceUpdate)
    }

    @Test
    func shouldForceUpdate_returnsTrueWhenSystemVersionEqualsMinimum() {
        let shouldForceUpdate = testee.shouldForceUpdate(
            appVersion: "4.9.0",
            systemVersion: "16.0",
            minimumSystemVersion: "16.0",
            belowAppVersion: "5.0.0"
        )
        #expect(shouldForceUpdate)
    }
}
