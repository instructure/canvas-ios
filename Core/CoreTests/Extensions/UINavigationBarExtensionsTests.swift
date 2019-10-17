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
        bar.useContextColor(.named(.licorice))
        XCTAssertEqual(bar.titleTextAttributes?[.foregroundColor] as? UIColor, .named(.white))
        XCTAssertEqual(bar.tintColor, .named(.white))
        XCTAssertEqual(bar.barTintColor, .named(.licorice))
        XCTAssertEqual(bar.barStyle, .black)
        XCTAssertFalse(bar.isTranslucent)
    }

    func testUseGlobalNavStyle() {
        let bar = UINavigationBar(frame: .zero)
        bar.useGlobalNavStyle()
        XCTAssertEqual(bar.titleTextAttributes?[.foregroundColor] as? UIColor, Brand.shared.navTextColor)
        XCTAssertEqual(bar.tintColor, Brand.shared.navTextColor)
        XCTAssertEqual(bar.barTintColor, Brand.shared.navBackground)
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
        XCTAssertEqual(bar.titleTextAttributes?[.foregroundColor] as? UIColor, Brand.shared.linkColor)
        XCTAssertEqual(bar.tintColor, Brand.shared.linkColor)
        XCTAssertEqual(bar.barTintColor, .named(.backgroundLightest))
        XCTAssertEqual(bar.barStyle, .default)
        XCTAssertFalse(bar.isTranslucent)
    }
}
