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
import SwiftUI
@testable import Core

class UIColorExtensionsTests: XCTestCase {
    func testHexString() {
        XCTAssertEqual(UIColor(hexString: "#12345678")?.hexString, "#12345678")
        XCTAssertNil(UIColor(hexString: "#1234567"))
        XCTAssertEqual(UIColor(hexString: "#aBCdef")?.hexString, "#abcdef")
        XCTAssertNil(UIColor(hexString: "#abcde"))
        XCTAssertEqual(UIColor(hexString: "#89ab")?.hexString, "#8899aabb")
        XCTAssertEqual(UIColor(hexString: "#aBc")?.hexString, "#aabbcc")
        XCTAssertNil(UIColor(hexString: "#ab"))
        XCTAssertNil(UIColor(hexString: "#1"))
        XCTAssertNil(UIColor(hexString: "123456"))
        XCTAssertNil(UIColor(hexString: "#nothex"))
    }

    func testIntValue() {
        XCTAssertEqual(UIColor(intValue: 0x12345678).intValue, 0x12345678)
    }

    func testLuminance() {
        XCTAssertEqual(UIColor.white.luminance, 1.0)
        XCTAssertEqual(UIColor.black.luminance, 0.0)
        XCTAssertEqual(UIColor.blue.luminance, 0.0722)
    }

    func testContrast() {
        XCTAssertEqual(UIColor.white.contrast(against: .black), 21.0)
        XCTAssertEqual(UIColor.black.contrast(against: .white), 21.0)
        XCTAssertEqual(UIColor.black.contrast(against: .blue), 2.44, accuracy: 0.01)
        XCTAssertEqual(UIColor.blue.contrast(against: .white), 8.59, accuracy: 0.01)
    }

    func testDarken() {
        XCTAssertEqual(UIColor.white.darkenToEnsureContrast(against: .white).hexString, "#757575")
        XCTAssertEqual(UIColor.white.darkenToEnsureContrast(against: UIColor(hexString: "#c0fefe")!).hexString, "#6d6d6d")
        XCTAssertEqual(UIColor.black.darkenToEnsureContrast(against: .white).hexString, UIColor.black.hexString)
    }

    func testEnsureContrast() {
        XCTAssertEqual(UIColor.black.ensureContrast(against: .blue).hexString, "#bcbcbc")
        XCTAssertEqual(UIColor.blue.ensureContrast(against: .black).hexString, "#5f5fff")
        XCTAssertEqual(UIColor.yellow.ensureContrast(against: .white).hexString, "#7a7a00")
    }

    func testCurrentLogoColor() {
        XCTAssertEqual(UIColor.currentLogoColor(for: Bundle.parentBundleID), UIColor.parentLogoColor)
        XCTAssertEqual(UIColor.currentLogoColor(for: Bundle.studentBundleID), UIColor.studentLogoColor)
        XCTAssertEqual(UIColor.currentLogoColor(for: Bundle.teacherBundleID), UIColor.teacherLogoColor)
        XCTAssertEqual(UIColor.currentLogoColor(), UIColor.studentLogoColor)
    }

    func testCustomColorInUnspecifiedTheme() {
        var sessionDefaults = SessionDefaults.fallback
        sessionDefaults.interfaceStyle = .unspecified
        AppEnvironment.shared.userDefaults = sessionDefaults
        XCTAssertEqual(UIColor.backgroundLightest.hexString, "#ffffff")
    }

    func testCustomColorInLightTheme() {
        var sessionDefaults = SessionDefaults.fallback
        sessionDefaults.interfaceStyle = .light
        AppEnvironment.shared.userDefaults = sessionDefaults
        XCTAssertEqual(UIColor.backgroundLightest.hexString, "#ffffff")
    }

    func testCustomColorInDarkTheme() {
        var sessionDefaults = SessionDefaults.fallback
        sessionDefaults.interfaceStyle = .dark
        AppEnvironment.shared.userDefaults = sessionDefaults
        XCTAssertEqual(UIColor.backgroundLightest.hexString, "#121212")
    }
}
