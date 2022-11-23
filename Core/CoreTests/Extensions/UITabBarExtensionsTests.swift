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
@testable import Core
import TestsFoundation

class UITabBarExtensionsTests: XCTestCase {
    func testUseGlobalNavStyle() {
        Brand.shared = Brand(
            response: APIBrandVariables.make(primary: "#333"),
            baseURL: URL(string: "https://canvas.instructure.com")!
        )
        let tabBar = UITabBar()
        tabBar.items = [ UITabBarItem(title: "", image: nil, selectedImage: nil) ]
        tabBar.useGlobalNavStyle()
        XCTAssertEqual(tabBar.tintColor.hexString, Brand.shared.primary.hexString)
        XCTAssertEqual(tabBar.barTintColor, UIColor.backgroundLightest)
        XCTAssertEqual(tabBar.unselectedItemTintColor, UIColor.textDark)
        XCTAssertEqual(tabBar.items?.first?.badgeColor, UIColor.crimson)
        XCTAssertEqual(tabBar.barStyle, .default)

        let shiny = Brand(response: APIBrandVariables.make(
            nav_text_color: "#333",
            primary: "#ffffff"
        ), baseURL: URL(string: "https://canvas.instructure.com")!)
        tabBar.useGlobalNavStyle(brand: shiny)
        XCTAssertEqual(tabBar.tintColor.hexString, shiny.navTextColor.hexString)
    }
}
