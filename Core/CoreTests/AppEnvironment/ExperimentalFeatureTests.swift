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
    let testFeature = ExperimentalFeature(rawValue: "favorite_groups")!

    override func setUp() {
        super.setUp()
        testFeature.isEnabled = false
    }

    func testSettingsKey() {
        XCTAssertEqual(testFeature.userDefaultsKey, "ExperimentalFeature.favorite_groups")
    }

    func testUsesUserDefaults() {
        UserDefaults.standard.set(true, forKey: testFeature.userDefaultsKey)
        XCTAssertTrue(testFeature.isEnabled)
        UserDefaults.standard.set(false, forKey: testFeature.userDefaultsKey)
    }

    func testSetsUserDefaults() {
        testFeature.isEnabled = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: testFeature.userDefaultsKey))
    }

    func testK5FlagDefaultValue() {
        UserDefaults.standard.removeObject(forKey: ExperimentalFeature.K5Dashboard.userDefaultsKey)
        XCTAssertTrue(ExperimentalFeature.K5Dashboard.isEnabled)
    }

    func testSavedDisabledK5FlagValue() {
        UserDefaults.standard.set(false, forKey: ExperimentalFeature.K5Dashboard.userDefaultsKey)
        XCTAssertFalse(ExperimentalFeature.K5Dashboard.isEnabled)
    }

    func testSavedEnabledK5FlagValue() {
        UserDefaults.standard.set(true, forKey: ExperimentalFeature.K5Dashboard.userDefaultsKey)
        XCTAssertTrue(ExperimentalFeature.K5Dashboard.isEnabled)
    }
}
