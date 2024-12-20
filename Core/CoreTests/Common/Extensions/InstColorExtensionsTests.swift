//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import UIKit
@testable import Core

class InstColorExtensionTests: XCTestCase {

    func testTextColors() {
        XCTAssertEqual(UIColor.textMasquerade, UIColor(resource: .textMasquerade))
        XCTAssertEqual(UIColor.textDanger, UIColor(resource: .textDanger))
        XCTAssertEqual(UIColor.textDark, UIColor(resource: .textDark))
        XCTAssertEqual(UIColor.textDarkest, UIColor(resource: .textDarkest))
        XCTAssertEqual(UIColor.textInfo, UIColor(resource: .textInfo))
        XCTAssertEqual(UIColor.textLight, UIColor(resource: .textLight))
        XCTAssertEqual(UIColor.textLightest, UIColor(resource: .textLightest))
        XCTAssertEqual(UIColor.textSuccess, UIColor(resource: .textSuccess))
        XCTAssertEqual(UIColor.textWarning, UIColor(resource: .textWarning))
        XCTAssertEqual(UIColor.textPlaceholder, UIColor(resource: .textPlaceholder))
        XCTAssertEqual(UIColor.textLink, UIColor(resource: .textLink))

        testHexColorEquality(UIColor.textMasquerade, Color.textMasquerade)
        testHexColorEquality(UIColor.textDanger, Color.textDanger)
        testHexColorEquality(UIColor.textDark, Color.textDark)
        testHexColorEquality(UIColor.textDarkest, Color.textDarkest)
        testHexColorEquality(UIColor.textInfo, Color.textInfo)
        testHexColorEquality(UIColor.textLight, Color.textLight)
        testHexColorEquality(UIColor.textLightest, Color.textLightest)
        testHexColorEquality(UIColor.textSuccess, Color.textSuccess)
        testHexColorEquality(UIColor.textWarning, Color.textWarning)
        testHexColorEquality(UIColor.textPlaceholder, Color.textPlaceholder)
        testHexColorEquality(UIColor.textLink, Color.textLink)
    }

    func testBackgroundColors() {
        XCTAssertEqual(UIColor.backgroundDanger, UIColor(resource: .backgroundDanger))
        XCTAssertEqual(UIColor.backgroundDark, UIColor(resource: .backgroundDark))
        XCTAssertEqual(UIColor.backgroundDarkest, UIColor(resource: .backgroundDarkest))
        XCTAssertEqual(UIColor.backgroundGrouped, UIColor(resource: .backgroundGrouped))
        XCTAssertEqual(UIColor.backgroundGroupedCell, UIColor(resource: .backgroundGroupedCell))
        XCTAssertEqual(UIColor.backgroundInfo, UIColor(resource: .backgroundInfo))
        XCTAssertEqual(UIColor.backgroundLight, UIColor(resource: .backgroundLight))
        XCTAssertEqual(UIColor.backgroundLightest, UIColor(resource: .backgroundLightest))
        XCTAssertEqual(UIColor.backgroundLightestElevated, UIColor(resource: .backgroundLightestElevated))
        XCTAssertEqual(UIColor.backgroundMasquerade, UIColor(resource: .backgroundMasquerade))
        XCTAssertEqual(UIColor.backgroundMedium, UIColor(resource: .backgroundMedium))
        XCTAssertEqual(UIColor.backgroundSuccess, UIColor(resource: .backgroundSuccess))
        XCTAssertEqual(UIColor.backgroundWarning, UIColor(resource: .backgroundWarning))

        testHexColorEquality(UIColor.backgroundDanger, Color.backgroundDanger)
        testHexColorEquality(UIColor.backgroundDark, Color.backgroundDark)
        testHexColorEquality(UIColor.backgroundDarkest, Color.backgroundDarkest)
        testHexColorEquality(UIColor.backgroundGrouped, Color.backgroundGrouped)
        testHexColorEquality(UIColor.backgroundGroupedCell, Color.backgroundGroupedCell)
        testHexColorEquality(UIColor.backgroundInfo, Color.backgroundInfo)
        testHexColorEquality(UIColor.backgroundLight, Color.backgroundLight)
        testHexColorEquality(UIColor.backgroundLightest, Color.backgroundLightest)
        testHexColorEquality(UIColor.backgroundLightestElevated, Color.backgroundLightestElevated)
        testHexColorEquality(UIColor.backgroundMasquerade, Color.backgroundMasquerade)
        testHexColorEquality(UIColor.backgroundMedium, Color.backgroundMedium)
        testHexColorEquality(UIColor.backgroundSuccess, Color.backgroundSuccess)
        testHexColorEquality(UIColor.backgroundWarning, Color.backgroundWarning)
    }

    func testBorderColors() {
        XCTAssertEqual(UIColor.borderDanger, UIColor(resource: .borderDanger))
        XCTAssertEqual(UIColor.borderDark, UIColor(resource: .borderDark))
        XCTAssertEqual(UIColor.borderDarkest, UIColor(resource: .borderDarkest))
        XCTAssertEqual(UIColor.borderDebug, UIColor(resource: .borderDebug))
        XCTAssertEqual(UIColor.borderInfo, UIColor(resource: .borderInfo))
        XCTAssertEqual(UIColor.borderLight, UIColor(resource: .borderLight))
        XCTAssertEqual(UIColor.borderLightest, UIColor(resource: .borderLightest))
        XCTAssertEqual(UIColor.borderMasquerade, UIColor(resource: .borderMasquerade))
        XCTAssertEqual(UIColor.borderMedium, UIColor(resource: .borderMedium))
        XCTAssertEqual(UIColor.borderSuccess, UIColor(resource: .borderSuccess))
        XCTAssertEqual(UIColor.borderWarning, UIColor(resource: .borderWarning))

        testHexColorEquality(UIColor.borderDanger, Color.borderDanger)
        testHexColorEquality(UIColor.borderDark, Color.borderDark)
        testHexColorEquality(UIColor.borderDarkest, Color.borderDarkest)
        testHexColorEquality(UIColor.borderDebug, Color.borderDebug)
        testHexColorEquality(UIColor.borderInfo, Color.borderInfo)
        testHexColorEquality(UIColor.borderLight, Color.borderLight)
        testHexColorEquality(UIColor.borderLightest, Color.borderLightest)
        testHexColorEquality(UIColor.borderMasquerade, Color.borderMasquerade)
        testHexColorEquality(UIColor.borderMedium, Color.borderMedium)
        testHexColorEquality(UIColor.borderSuccess, Color.borderSuccess)
        testHexColorEquality(UIColor.borderWarning, Color.borderWarning)
    }

    func testCourseColors() {
        XCTAssertEqual(UIColor.course1, UIColor(resource: .course1))
        XCTAssertEqual(UIColor.course2, UIColor(resource: .course2))
        XCTAssertEqual(UIColor.course3, UIColor(resource: .course3))
        XCTAssertEqual(UIColor.course4, UIColor(resource: .course4))
        XCTAssertEqual(UIColor.course5, UIColor(resource: .course5))
        XCTAssertEqual(UIColor.course6, UIColor(resource: .course6))
        XCTAssertEqual(UIColor.course7, UIColor(resource: .course7))
        XCTAssertEqual(UIColor.course8, UIColor(resource: .course8))
        XCTAssertEqual(UIColor.course9, UIColor(resource: .course9))
        XCTAssertEqual(UIColor.course10, UIColor(resource: .course10))
        XCTAssertEqual(UIColor.course11, UIColor(resource: .course11))
        XCTAssertEqual(UIColor.course12, UIColor(resource: .course12))

        testHexColorEquality(UIColor.course1, Color.course1)
        testHexColorEquality(UIColor.course2, Color.course2)
        testHexColorEquality(UIColor.course3, Color.course3)
        testHexColorEquality(UIColor.course4, Color.course4)
        testHexColorEquality(UIColor.course5, Color.course5)
        testHexColorEquality(UIColor.course6, Color.course6)
        testHexColorEquality(UIColor.course7, Color.course7)
        testHexColorEquality(UIColor.course8, Color.course8)
        testHexColorEquality(UIColor.course9, Color.course9)
        testHexColorEquality(UIColor.course10, Color.course10)
        testHexColorEquality(UIColor.course11, Color.course11)
        testHexColorEquality(UIColor.course12, Color.course12)
    }

    func testIOSSpecificColors() {
        XCTAssertEqual(UIColor.disabledGray, UIColor(resource: .disabledGray))
        testHexColorEquality(UIColor.disabledGray, Color.disabledGray)
    }

    func testHexColorEquality(_ uiColor: UIColor, _ color: Color) {
        XCTAssertEqual(
            uiColor.variantForLightMode.hexString,
            color.variantForLightMode.hexString,
            "\(uiColor)"
        )
        XCTAssertEqual(
            uiColor.variantForDarkMode.hexString,
            color.variantForDarkMode.hexString,
            "\(uiColor)"
        )
    }
}
