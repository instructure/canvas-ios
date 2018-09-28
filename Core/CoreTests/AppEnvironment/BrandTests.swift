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

class BrandTests: XCTestCase {
    func testApplyToWindow() {
        let window = UIWindow()
        let tinter = UIView()
        Brand.shared.apply(to: window)
        tinter.tintColor = Brand.shared.primary
        XCTAssertEqual(window.tintColor, tinter.tintColor)
        XCTAssertEqual(UITabBar.appearance().tintColor, Brand.shared.primary)
        XCTAssertEqual(UINavigationBar.appearance().backIndicatorImage, .icon(.back))
    }

    func testApplyToNavBar() {
        let navBar = UINavigationBar(frame: .zero)
        let tinter = UIView()
        Brand.shared.apply(to: navBar)
        XCTAssertEqual(navBar.barTintColor, Brand.shared.navBackground)
        tinter.tintColor = Brand.shared.navIconFill
        XCTAssertEqual(navBar.tintColor, tinter.tintColor)
        XCTAssertEqual(navBar.barStyle, .black)

        let shiny = Brand(
            buttonPrimaryBackground: .white,
            buttonPrimaryText: .white,
            buttonSecondaryBackground: .white,
            buttonSecondaryText: .white,
            fontColorDark: .white,
            headerImageUrl: nil,
            linkColor: .white,
            navBackground: .white,
            navIconFill: .white,
            navTextColor: .white,
            primary: .white
        )
        shiny.apply(to: navBar)
        XCTAssertEqual(navBar.barStyle, .default)
    }
}
