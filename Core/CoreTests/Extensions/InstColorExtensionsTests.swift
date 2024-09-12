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

    func testUIColor() {
        XCTAssertEqual(UIColor.ash, UIColor(named: "ash", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.barney, UIColor(named: "barney", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderAlert, UIColor(named: "borderAlert", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderDanger, UIColor(named: "borderDanger", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderDark, UIColor(named: "borderDark", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderDarkest, UIColor(named: "borderDarkest", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderInfo, UIColor(named: "borderInfo", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderLight, UIColor(named: "borderLight", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderLightest, UIColor(named: "borderLightest", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderMedium, UIColor(named: "borderMedium", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderSuccess, UIColor(named: "borderSuccess", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.borderWarning, UIColor(named: "borderWarning", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.crimson, UIColor(named: "crimson", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.disabledGray, UIColor(named: "disabledGray", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.electric, UIColor(named: "electric", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.fire, UIColor(named: "fire", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.licorice, UIColor(named: "licorice", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.oxford, UIColor(named: "oxford", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.placeholderGray, UIColor(named: "placeholderGray", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.porcelain, UIColor(named: "porcelain", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.shamrock, UIColor(named: "shamrock", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.tabBarBackground, UIColor(named: "tabBarBackground", in: .core, compatibleWith: nil))
        XCTAssertEqual(UIColor.tiara, UIColor(named: "tiara", in: .core, compatibleWith: nil))
    }

    func testColor() {
        XCTAssertEqual(Color.ash, Color("ash", bundle: .core))
        XCTAssertEqual(Color.barney, Color("barney", bundle: .core))
        XCTAssertEqual(Color.borderAlert, Color("borderAlert", bundle: .core))
        XCTAssertEqual(Color.borderDanger, Color("borderDanger", bundle: .core))
        XCTAssertEqual(Color.borderDark, Color("borderDark", bundle: .core))
        XCTAssertEqual(Color.borderDarkest, Color("borderDarkest", bundle: .core))
        XCTAssertEqual(Color.borderInfo, Color("borderInfo", bundle: .core))
        XCTAssertEqual(Color.borderLight, Color("borderLight", bundle: .core))
        XCTAssertEqual(Color.borderLightest, Color("borderLightest", bundle: .core))
        XCTAssertEqual(Color.borderMedium, Color("borderMedium", bundle: .core))
        XCTAssertEqual(Color.borderSuccess, Color("borderSuccess", bundle: .core))
        XCTAssertEqual(Color.borderWarning, Color("borderWarning", bundle: .core))
        XCTAssertEqual(Color.crimson, Color("crimson", bundle: .core))
        XCTAssertEqual(Color.disabledGray, Color("disabledGray", bundle: .core))
        XCTAssertEqual(Color.electric, Color("electric", bundle: .core))
        XCTAssertEqual(Color.electricHighContrast, Color("electricHighContrast", bundle: .core))
        XCTAssertEqual(Color.fire, Color("fire", bundle: .core))
        XCTAssertEqual(Color.licorice, Color("licorice", bundle: .core))
        XCTAssertEqual(Color.oxford, Color("oxford", bundle: .core))
        XCTAssertEqual(Color.placeholderGray, Color("placeholderGray", bundle: .core))
        XCTAssertEqual(Color.porcelain, Color("porcelain", bundle: .core))
        XCTAssertEqual(Color.shamrock, Color("shamrock", bundle: .core))
        XCTAssertEqual(Color.tabBarBackground, Color("tabBarBackground", bundle: .core))
        XCTAssertEqual(Color.tiara, Color("tiara", bundle: .core))
    }
}
