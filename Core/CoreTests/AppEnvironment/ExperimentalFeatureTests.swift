//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class ExperimentalFeatureTests: CoreTestCase {
    let testFeature = ExperimentalFeature(remoteConfigKey: "test")
    let settingsKey = ExperimentalFeature.settingsKey(forConfigKey: "test")

    override func setUp() {
        super.setUp()
        testFeature.isEnabled = false
    }

    func testSettingsKey() {
        XCTAssertEqual(settingsKey, "ExperimentalFeature.test")
    }

    func testUsesRemoteConfigKeyInSettingsKey() {
        XCTAssertEqual(testFeature.settingsKey, settingsKey)
    }

    func testUsesUserDefaultsByDefault() {
        UserDefaults.standard.set(true, forKey: "ExperimentalFeature.default")
        XCTAssertTrue(ExperimentalFeature(remoteConfigKey: "default").isEnabled)
    }

    func testSetsUserDefaults() {
        testFeature.isEnabled = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: ExperimentalFeature.settingsKey(forConfigKey: "test")))
    }
}
