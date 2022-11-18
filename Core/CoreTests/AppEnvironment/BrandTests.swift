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
        XCTAssertEqual(Brand.shared.color("buttonPrimaryBackground")?.difference(to: Brand.shared.buttonPrimaryBackground), 0)
        XCTAssertEqual(Brand.shared.color("buttonPrimaryText")?.difference(to: Brand.shared.buttonPrimaryText), 0)
        XCTAssertEqual(Brand.shared.color("buttonSecondaryBackground")?.difference(to: Brand.shared.buttonSecondaryBackground), 0)
        XCTAssertEqual(Brand.shared.color("buttonSecondaryText")?.difference(to: Brand.shared.buttonSecondaryText), 0)
        XCTAssertEqual(Brand.shared.color("fontColorDark")?.difference(to: Brand.shared.fontColorDark), 0)
        XCTAssertEqual(Brand.shared.color("headerImageBackground")?.difference(to: Brand.shared.headerImageBackground), 0)
        XCTAssertEqual(Brand.shared.color("linkColor")?.difference(to: Brand.shared.linkColor), 0)
        XCTAssertEqual(Brand.shared.color("navBackground")?.difference(to: Brand.shared.navBackground), 0)
        XCTAssertEqual(Brand.shared.color("navBadgeBackground")?.difference(to: Brand.shared.navBadgeBackground), 0)
        XCTAssertEqual(Brand.shared.color("navBadgeText")?.difference(to: Brand.shared.navBadgeText), 0)
        XCTAssertEqual(Brand.shared.color("navIconFill")?.difference(to: Brand.shared.navIconFill), 0)
        XCTAssertEqual(Brand.shared.color("navIconFillActive")?.difference(to: Brand.shared.navIconFillActive), 0)
        XCTAssertEqual(Brand.shared.color("navTextColor")?.difference(to: Brand.shared.navTextColor), 0)
        XCTAssertEqual(Brand.shared.color("navTextColorActive")?.difference(to: Brand.shared.navTextColorActive), 0)
        XCTAssertEqual(Brand.shared.color("primary")?.difference(to: Brand.shared.primary), 0)
        XCTAssertEqual(Brand.shared.color("ash"), .ash)
        XCTAssertNil(Brand.shared.color("not a real name"))
    }

    func testHeaderImageView() {
        let view = Brand.shared.headerImageView()
        view.layoutIfNeeded()
        XCTAssertEqual(view.backgroundColor?.difference(to: Brand.shared.headerImageBackground), 0)
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 44, height: 44))
        XCTAssertEqual(view.url, Brand.shared.headerImageUrl)
    }
}
