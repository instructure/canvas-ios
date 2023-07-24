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
import UIKit
@testable import Core

class UINavigationBarExtensionsTests: XCTestCase {
    func testUseContextColor() {
        let bar = UINavigationBar(frame: .zero)
        bar.useContextColor(.licorice)
        XCTAssertEqual((bar.titleTextAttributes?[.foregroundColor] as? UIColor)?.hexString, UIColor.white.hexString)
        XCTAssertEqual(bar.tintColor.hexString, UIColor.white.hexString)
        XCTAssertEqual(bar.barTintColor?.hexString, UIColor.licorice.hexString)
        XCTAssertEqual(bar.barStyle, .black)
        XCTAssertFalse(bar.isTranslucent)
    }

    func testUseGlobalNavStyle() {
        let bar = UINavigationBar(frame: .zero)
        bar.useGlobalNavStyle()
        XCTAssertEqual((bar.titleTextAttributes?[.foregroundColor] as? UIColor)!.hexString, Brand.shared.navTextColor.hexString)
        XCTAssertEqual(bar.tintColor.hexString, Brand.shared.navTextColor.hexString)
        XCTAssertEqual(bar.barTintColor!.hexString, Brand.shared.navBackground.hexString)
        XCTAssertEqual(bar.barStyle, .black)
        XCTAssertFalse(bar.isTranslucent)

        let shiny = Brand(
            buttonPrimaryBackground: .white,
            buttonPrimaryText: .white,
            buttonSecondaryBackground: .white,
            buttonSecondaryText: .white,
            fontColorDark: .white,
            headerImageBackground: .white,
            headerImageUrl: nil,
            linkColor: .white,
            navBackground: .white,
            navBadgeBackground: .white,
            navBadgeText: .white,
            navIconFill: .white,
            navIconFillActive: .white,
            navTextColor: .white,
            navTextColorActive: .white,
            primary: .white
        )
        bar.useGlobalNavStyle(brand: shiny)
        XCTAssertEqual(bar.barStyle, .default)
    }

    func testUseModalStyle() {
        let bar = UINavigationBar(frame: .zero)
        bar.useModalStyle()
        XCTAssertEqual(bar.titleTextAttributes?[.foregroundColor] as? UIColor, .textDarkest)
        XCTAssertEqual(bar.tintColor.hexString, Brand.shared.linkColor.hexString)
        XCTAssertEqual(bar.barTintColor, .backgroundLightest)
        XCTAssertEqual(bar.barStyle, .default)
        XCTAssertFalse(bar.isTranslucent)
    }
}
