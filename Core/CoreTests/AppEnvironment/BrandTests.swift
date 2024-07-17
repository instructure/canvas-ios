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
        XCTAssertEqual(Brand.shared.color("buttonPrimaryBackground")!.hexString, Brand.shared.buttonPrimaryBackground.hexString)
        XCTAssertEqual(Brand.shared.color("buttonPrimaryText")!.hexString, Brand.shared.buttonPrimaryText.hexString)
        XCTAssertEqual(Brand.shared.color("buttonSecondaryBackground")!.hexString, Brand.shared.buttonSecondaryBackground.hexString)
        XCTAssertEqual(Brand.shared.color("buttonSecondaryText")!.hexString, Brand.shared.buttonSecondaryText.hexString)
        XCTAssertEqual(Brand.shared.color("fontColorDark")!.hexString, Brand.shared.fontColorDark.hexString)
        XCTAssertEqual(Brand.shared.color("headerImageBackground")!.hexString, Brand.shared.headerImageBackground.hexString)
        XCTAssertEqual(Brand.shared.color("linkColor")!.hexString, Brand.shared.linkColor.hexString)
        XCTAssertEqual(Brand.shared.color("navBackground")!.hexString, Brand.shared.navBackground.hexString)
        XCTAssertEqual(Brand.shared.color("navBadgeBackground")!.hexString, Brand.shared.navBadgeBackground.hexString)
        XCTAssertEqual(Brand.shared.color("navBadgeText")!.hexString, Brand.shared.navBadgeText.hexString)
        XCTAssertEqual(Brand.shared.color("navIconFill")!.hexString, Brand.shared.navIconFill.hexString)
        XCTAssertEqual(Brand.shared.color("navIconFillActive")!.hexString, Brand.shared.navIconFillActive.hexString)
        XCTAssertEqual(Brand.shared.color("navTextColor")!.hexString, Brand.shared.navTextColor.hexString)
        XCTAssertEqual(Brand.shared.color("navTextColorActive")!.hexString, Brand.shared.navTextColorActive.hexString)
        XCTAssertEqual(Brand.shared.color("primary")!.hexString, Brand.shared.primary.hexString)
        XCTAssertEqual(Brand.shared.color("ash"), .ash)
        XCTAssertNil(Brand.shared.color("not a real name"))
    }

    func testHeaderImageView() {
        let headerImage = UIImage.addImageLine
        Brand.shared.headerImage = headerImage
        let view = Brand.shared.headerImageView()
        view.layoutIfNeeded()
        XCTAssertEqual(view.backgroundColor!.hexString, Brand.shared.headerImageBackground.hexString)
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 44, height: 44))
        XCTAssertEqual(view.image, headerImage)
    }
}
