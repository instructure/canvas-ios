//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import UIKit
@testable import Core

class UIApplicationDelegateExtensionsTests: XCTestCase {

    func testUpdateInterfaceStyle() {
        guard let appDelegate = UIApplication.shared.delegate else { return XCTFail() }
        AppEnvironment.shared.userDefaults?.interfaceStyle = .dark
        appDelegate.updateInterfaceStyle(for: appDelegate.window!)
        XCTAssertEqual(appDelegate.window!?.overrideUserInterfaceStyle, .dark)
        AppEnvironment.shared.userDefaults?.interfaceStyle = .light
        appDelegate.updateInterfaceStyle(for: appDelegate.window!)
        XCTAssertEqual(appDelegate.window!?.overrideUserInterfaceStyle, .light)
        AppEnvironment.shared.userDefaults?.interfaceStyle = .unspecified
        appDelegate.updateInterfaceStyle(for: appDelegate.window!)
        XCTAssertEqual(appDelegate.window!?.overrideUserInterfaceStyle, .unspecified)
    }
}
