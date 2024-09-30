//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class CourseColorsInteractorLiveTests: XCTestCase {
    private var testee: CourseColorsInteractorLive!

    override func setUp() {
        super.setUp()
        testee = CourseColorsInteractorLive()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testColorsSupportDarkMode() {
        for (color, _) in testee.colors {
            XCTAssertNotEqual(color.variantForLightMode, color.variantForDarkMode)
        }

        XCTAssertEqual(testee.colors.count, 12)
    }

    func testPredefinedColorMapping() {
        let plumColorHex = UIColor(hexString: UIColor.course1.variantForLightMode.hexString)!

        let result = testee.courseColorFromAPIColor(plumColorHex)

        XCTAssertEqual(result, .course1)
    }

    func testCustomColorMapping() {
        let customColor = UIColor(hexString: "#123456")!
        let expected = UIColor.getColor(
            dark: customColor.ensureContrast(against: .backgroundLightest.variantForDarkMode),
            light: customColor.darkenToEnsureContrast(against: .backgroundLightest.variantForLightMode)
        )

        let result = testee.courseColorFromAPIColor(customColor)

        XCTAssertEqual(result.variantForLightMode, expected.variantForLightMode)
        XCTAssertEqual(result.variantForDarkMode, expected.variantForDarkMode)
    }

    func testFallbackColorOnInvalidAPIColor() {
        let invalidColor = "#FF"

        let result = testee.courseColorFromAPIColor(invalidColor)

        XCTAssertEqual(result, .textDarkest)
    }
}
