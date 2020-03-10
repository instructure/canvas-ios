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

    func testHeaderImageView() {
        let view = Brand.shared.headerImageView()
        view.layoutIfNeeded()
        XCTAssertEqual(view.backgroundColor, Brand.shared.headerImageBackground)
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 44, height: 44))
        XCTAssertEqual(view.url, Brand.shared.headerImageUrl)
    }
}
