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
import UIKit
@testable import Core

class UINavigationBarExtensionsTests: XCTestCase {
    func testUseContextColor() {
        let bar = UINavigationBar(frame: .zero)
        bar.useContextColor(.named(.backgroundDarkest))
        XCTAssertEqual(bar.tintColor, .named(.textLightest))
        XCTAssertEqual(bar.barTintColor, .named(.backgroundDarkest))
        XCTAssertEqual(bar.barStyle, .black)
        XCTAssertFalse(bar.isTranslucent)
    }

    func testUseGlobalNavStyle() {
        let bar = UINavigationBar(frame: .zero)
        bar.useGlobalNavStyle()
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
        XCTAssertEqual(bar.tintColor, Brand.shared.linkColor)
        XCTAssertEqual(bar.barTintColor, .named(.backgroundLightest))
        XCTAssertEqual(bar.barStyle, .default)
        XCTAssertTrue(bar.isTranslucent)
    }
}
