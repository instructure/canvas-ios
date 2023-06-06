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
        let appearance = tabBar.standardAppearance.stackedLayoutAppearance
        let normal = appearance.normal
        let selected = appearance.selected

        XCTAssertEqual(selected.iconColor?.hexString, Brand.shared.primary.hexString)
        XCTAssertEqual(normal.iconColor, UIColor.textDark)

        XCTAssertEqual(normal.titleTextAttributes[.foregroundColor] as! UIColor, UIColor.textDark)
        XCTAssertEqual((selected.titleTextAttributes[.foregroundColor] as! UIColor).hexString, Brand.shared.primary.hexString)

        XCTAssertEqual(tabBar.standardAppearance.backgroundColor, UIColor.tabBarBackground)
        XCTAssertEqual(tabBar.items?.first?.badgeColor, UIColor.crimson)
        XCTAssertEqual(tabBar.barStyle, .default)

        let shiny = Brand(response: APIBrandVariables.make(
            nav_text_color: "#333",
            primary: "#ffffff"
        ), baseURL: URL(string: "https://canvas.instructure.com")!)
        tabBar.useGlobalNavStyle(brand: shiny)
        XCTAssertEqual(tabBar.standardAppearance.stackedLayoutAppearance.selected.iconColor?.hexString, shiny.primary.darkenToEnsureContrast(against: .backgroundLightest).hexString)
    }
}
