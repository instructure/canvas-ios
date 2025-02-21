//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class NavigationBarColorConfigurationTests: XCTestCase {

    let brand = Brand(
        response: .make(
            button_primary_bgd: "#FFFF00",
            link_color: "#FF0000",
            nav_text_color: "#0000FF"
        ),
        headerImage: nil
    )

    func test_colors_whenStyleIsModal() {
        let testee = NavigationBarColorConfiguration(style: .modal, brand: brand)

        XCTAssertEqual(testee.title.hexString, Color.textDarkest.hexString)
        XCTAssertEqual(testee.subtitle.hexString, Color.textDark.hexString)
        XCTAssertEqual(testee.tint.hexString, brand.linkColor.hexString)
    }

    func test_colors_whenStyleIsGlobal() {
        let testee = NavigationBarColorConfiguration(style: .global, brand: brand)

        XCTAssertEqual(testee.title.hexString, brand.navTextColor.hexString)
        XCTAssertEqual(testee.subtitle.hexString, brand.navTextColor.hexString)
        XCTAssertEqual(testee.tint.hexString, brand.navTextColor.hexString)
    }

    func test_colors_whenStyleIsColor() {
        let testee = NavigationBarColorConfiguration(style: .color(.purple), brand: brand)

        XCTAssertEqual(testee.title.hexString, Color.textLightest.hexString)
        XCTAssertEqual(testee.subtitle.hexString, Color.textLightest.hexString)
        XCTAssertEqual(testee.tint.hexString, Color.textLightest.hexString)
    }

    func test_colors_whenStyleIsColorWithNil() {
        let testee = NavigationBarColorConfiguration(style: .color(nil), brand: brand)

        XCTAssertEqual(testee.title.hexString, Color.textLightest.hexString)
        XCTAssertEqual(testee.subtitle.hexString, Color.textLightest.hexString)
        XCTAssertEqual(testee.tint.hexString, Color.textLightest.hexString)
    }
}
