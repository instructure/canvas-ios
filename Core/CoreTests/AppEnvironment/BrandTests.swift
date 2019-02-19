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
    func testColor() {
        XCTAssertEqual(Brand.shared.color("buttonPrimaryBackground"), Brand.shared.buttonPrimaryBackground)
        XCTAssertEqual(Brand.shared.color("buttonPrimaryText"), Brand.shared.buttonPrimaryText)
        XCTAssertEqual(Brand.shared.color("buttonSecondaryBackground"), Brand.shared.buttonSecondaryBackground)
        XCTAssertEqual(Brand.shared.color("buttonSecondaryText"), Brand.shared.buttonSecondaryText)
        XCTAssertEqual(Brand.shared.color("fontColorDark"), Brand.shared.fontColorDark)
        XCTAssertEqual(Brand.shared.color("headerImageBackground"), Brand.shared.headerImageBackground)
        XCTAssertEqual(Brand.shared.color("linkColor"), Brand.shared.linkColor)
        XCTAssertEqual(Brand.shared.color("navBackground"), Brand.shared.navBackground)
        XCTAssertEqual(Brand.shared.color("navBadgeBackground"), Brand.shared.navBadgeBackground)
        XCTAssertEqual(Brand.shared.color("navBadgeText"), Brand.shared.navBadgeText)
        XCTAssertEqual(Brand.shared.color("navIconFill"), Brand.shared.navIconFill)
        XCTAssertEqual(Brand.shared.color("navIconFillActive"), Brand.shared.navIconFillActive)
        XCTAssertEqual(Brand.shared.color("navTextColor"), Brand.shared.navTextColor)
        XCTAssertEqual(Brand.shared.color("navTextColorActive"), Brand.shared.navTextColorActive)
        XCTAssertEqual(Brand.shared.color("primary"), Brand.shared.primary)
        XCTAssertEqual(Brand.shared.color("ash"), .named(.ash))
        XCTAssertNil(Brand.shared.color("not a real name"))
    }
}
