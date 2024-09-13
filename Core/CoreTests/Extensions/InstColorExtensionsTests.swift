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

        XCTAssertEqual(Color.textMasquerade, Color(.textMasquerade))
        XCTAssertEqual(Color.textDanger, Color(.textDanger))
        XCTAssertEqual(Color.textDark, Color(.textDark))
        XCTAssertEqual(Color.textDarkest, Color(.textDarkest))
        XCTAssertEqual(Color.textInfo, Color(.textInfo))
        XCTAssertEqual(Color.textLight, Color(.textLight))
        XCTAssertEqual(Color.textLightest, Color(.textLightest))
        XCTAssertEqual(Color.textSuccess, Color(.textSuccess))
        XCTAssertEqual(Color.textWarning, Color(.textWarning))
        XCTAssertEqual(Color.textPlaceholder, Color(.textPlaceholder))
        XCTAssertEqual(Color.textLink, Color(.textLink))
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

        XCTAssertEqual(Color.backgroundDanger, Color(.backgroundDanger))
        XCTAssertEqual(Color.backgroundDark, Color(.backgroundDark))
        XCTAssertEqual(Color.backgroundDarkest, Color(.backgroundDarkest))
        XCTAssertEqual(Color.backgroundGrouped, Color(.backgroundGrouped))
        XCTAssertEqual(Color.backgroundGroupedCell, Color(.backgroundGroupedCell))
        XCTAssertEqual(Color.backgroundInfo, Color(.backgroundInfo))
        XCTAssertEqual(Color.backgroundLight, Color(.backgroundLight))
        XCTAssertEqual(Color.backgroundLightest, Color(.backgroundLightest))
        XCTAssertEqual(Color.backgroundLightestElevated, Color(.backgroundLightestElevated))
        XCTAssertEqual(Color.backgroundMasquerade, Color(.backgroundMasquerade))
        XCTAssertEqual(Color.backgroundMedium, Color(.backgroundMedium))
        XCTAssertEqual(Color.backgroundSuccess, Color(.backgroundSuccess))
        XCTAssertEqual(Color.backgroundWarning, Color(.backgroundWarning))
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

        XCTAssertEqual(Color.borderDanger, Color(.borderDanger))
        XCTAssertEqual(Color.borderDark, Color(.borderDark))
        XCTAssertEqual(Color.borderDarkest, Color(.borderDarkest))
        XCTAssertEqual(Color.borderDebug, Color(.borderDebug))
        XCTAssertEqual(Color.borderInfo, Color(.borderInfo))
        XCTAssertEqual(Color.borderLight, Color(.borderLight))
        XCTAssertEqual(Color.borderLightest, Color(.borderLightest))
        XCTAssertEqual(Color.borderMasquerade, Color(.borderMasquerade))
        XCTAssertEqual(Color.borderMedium, Color(.borderMedium))
        XCTAssertEqual(Color.borderSuccess, Color(.borderSuccess))
        XCTAssertEqual(Color.borderWarning, Color(.borderWarning))
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

        XCTAssertEqual(Color.course1, Color(.course1))
        XCTAssertEqual(Color.course2, Color(.course2))
        XCTAssertEqual(Color.course3, Color(.course3))
        XCTAssertEqual(Color.course4, Color(.course4))
        XCTAssertEqual(Color.course5, Color(.course5))
        XCTAssertEqual(Color.course6, Color(.course6))
        XCTAssertEqual(Color.course7, Color(.course7))
        XCTAssertEqual(Color.course8, Color(.course8))
        XCTAssertEqual(Color.course9, Color(.course9))
        XCTAssertEqual(Color.course10, Color(.course10))
        XCTAssertEqual(Color.course11, Color(.course11))
        XCTAssertEqual(Color.course12, Color(.course12))
    }

    func testUIColor() {
        XCTAssertEqual(UIColor.ash, UIColor(named: "ash", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.disabledGray, UIColor(named: "disabledGray", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.electric, UIColor(named: "electric", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.licorice, UIColor(named: "licorice", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.oxford, UIColor(named: "oxford", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.placeholderGray, UIColor(named: "placeholderGray", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.porcelain, UIColor(named: "porcelain", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.tabBarBackground, UIColor(named: "tabBarBackground", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.tiara, UIColor(named: "tiara", in: .core, compatibleWith: nil))
    }

    func testColor() {
        XCTAssertEqual(Color.ash, Color("ash", bundle: .core))
        XCTAssertEqual(Color.disabledGray, Color("disabledGray", bundle: .core))
        XCTAssertEqual(Color.electric, Color("electric", bundle: .core))
        XCTAssertEqual(Color.electricHighContrast, Color("electricHighContrast", bundle: .core))
        XCTAssertEqual(Color.licorice, Color("licorice", bundle: .core))
        XCTAssertEqual(Color.oxford, Color("oxford", bundle: .core))
        XCTAssertEqual(Color.placeholderGray, Color("placeholderGray", bundle: .core))
        XCTAssertEqual(Color.porcelain, Color("porcelain", bundle: .core))
        XCTAssertEqual(Color.tabBarBackground, Color("tabBarBackground", bundle: .core))
        XCTAssertEqual(Color.tiara, Color("tiara", bundle: .core))
    }
}
