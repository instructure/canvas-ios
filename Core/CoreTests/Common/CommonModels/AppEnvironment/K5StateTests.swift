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
import TestsFoundation
@testable import Core

class K5StateTests: CoreTestCase {

    override func setUp() {
        super.setUp()
        ExperimentalFeature.K5Dashboard.isEnabled = false
        environment.userDefaults?.isElementaryViewEnabled = false
    }

    func testK5AccountStateUpdates() {
        let testee = K5State()
        XCTAssertFalse(testee.isK5Account)

        testee.userDidLogin(isK5Account: true)
        XCTAssertTrue(testee.isK5Account)

        testee.userDidLogin(isK5Account: false)
        XCTAssertFalse(testee.isK5Account)

        testee.userDidLogin(profile: nil)
        XCTAssertFalse(testee.isK5Account)

        testee.userDidLogin(profile: APIProfile.make(k5_user: nil))
        XCTAssertFalse(testee.isK5Account)

        testee.userDidLogin(profile: APIProfile.make(k5_user: false))
        XCTAssertFalse(testee.isK5Account)

        testee.userDidLogin(profile: APIProfile.make(k5_user: true))
        XCTAssertTrue(testee.isK5Account)

        testee.userDidLogin(profile: APIProfile.make(k5_user: false), isK5StudentView: true)
        XCTAssertTrue(testee.isK5Account)
    }

    func testLogoutUpdatesK5AccountState() {
        let testee = K5State()
        testee.userDidLogin(isK5Account: true)
        XCTAssertTrue(testee.isK5Account)

        testee.userDidLogout()
        XCTAssertFalse(testee.isK5Account)
    }

    func testK5ModeDepencies() {
        let testee = K5State()
        testee.sessionDefaults = environment.userDefaults
        XCTAssertFalse(testee.isK5Account)
        XCTAssertFalse(testee.isK5Enabled)
        XCTAssertFalse(testee.isElementaryViewEnabled)

        testee.userDidLogin(isK5Account: true)
        XCTAssertFalse(testee.isK5Enabled)

        ExperimentalFeature.K5Dashboard.isEnabled = true
        XCTAssertFalse(testee.isK5Enabled)

        environment.userDefaults?.isElementaryViewEnabled = true
        XCTAssertTrue(testee.isK5Enabled)

        testee.userDidLogin(isK5Account: false)
        XCTAssertFalse(testee.isK5Enabled)
    }

    func testFontAppearanceUpdated() {
        ExperimentalFeature.K5Dashboard.isEnabled = true
        environment.userDefaults?.isElementaryViewEnabled = true
        AppEnvironment.shared.k5.userDidLogin(isK5Account: false)

        let oldBarButtonItemFont = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).titleTextAttributes(for: .normal)![NSAttributedString.Key.font] as! UIFont?
        let oldSegmentedControlNormalFont = UISegmentedControl.appearance().titleTextAttributes(for: .normal)![NSAttributedString.Key.font] as! UIFont?
        let oldSegmentedControlSelectedFont = UISegmentedControl.appearance().titleTextAttributes(for: .selected)![NSAttributedString.Key.font] as! UIFont?

        AppEnvironment.shared.k5.userDidLogin(isK5Account: true)

        let newBarButtonItemFont = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).titleTextAttributes(for: .normal)![NSAttributedString.Key.font] as! UIFont?
        let newSegmentedControlNormalFont = UISegmentedControl.appearance().titleTextAttributes(for: .normal)![NSAttributedString.Key.font] as! UIFont?
        let newSegmentedControlSelectedFont = UISegmentedControl.appearance().titleTextAttributes(for: .selected)![NSAttributedString.Key.font] as! UIFont?

        XCTAssertNotEqual(oldBarButtonItemFont, newBarButtonItemFont)
        XCTAssertNotEqual(oldSegmentedControlNormalFont, newSegmentedControlNormalFont)
        XCTAssertNotEqual(oldSegmentedControlSelectedFont, newSegmentedControlSelectedFont)
    }
}
