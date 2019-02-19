//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core
import TestsFoundation

class UITabBarExtensionsTests: XCTestCase {
    func testUseGlobalNavStyle() {
        let tabBar = UITabBar()
        tabBar.items = [ UITabBarItem(title: "", image: nil, selectedImage: nil) ]
        tabBar.useGlobalNavStyle()
        XCTAssertNotNil(tabBar.selectionIndicatorImage)
        XCTAssertEqual(tabBar.tintColor, Brand.shared.navIconFillActive)
        XCTAssertEqual(tabBar.barTintColor, Brand.shared.navBackground)
        XCTAssertEqual(tabBar.unselectedItemTintColor, Brand.shared.navIconFill)
        XCTAssertEqual(tabBar.items?.first?.badgeColor, Brand.shared.navBadgeBackground)
        XCTAssertEqual(tabBar.barStyle, .black)

        let shiny = Brand(response: APIBrandVariables.make([ "ic-brand-global-nav-bgd": "#ffffff" ]))
        tabBar.useGlobalNavStyle(brand: shiny)
        XCTAssertEqual(tabBar.barStyle, .default)
    }
}
