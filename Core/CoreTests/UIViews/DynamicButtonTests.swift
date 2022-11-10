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

class DynamicButtonTests: XCTestCase {
    func testBackgroundColorName() {
        let view = DynamicButton()
        view.backgroundColorName = "not a color name"
        XCTAssertNil(view.backgroundColor)
        view.backgroundColorName = "electric"
        XCTAssertEqual(view.backgroundColor, .electric)
    }

    func testBorderColorName() {
        let view = DynamicButton()
        view.borderColorName = "not a color name"
        XCTAssertEqual(view.layer.borderWidth, 0)
        view.borderColorName = "electric"
        XCTAssertEqual(view.layer.borderColor, UIColor.electric.cgColor)
        XCTAssertEqual(view.layer.borderWidth, 0.5)
    }

    func testIconName() {
        let view = DynamicButton()
        view.iconName = "not an icon name"
        XCTAssertNil(view.image(for: .normal))
        view.iconName = "instructureSolid"
        XCTAssertEqual(view.image(for: .normal), .instructureSolid)
    }

    func testTextColorName() {
        let view = DynamicButton()
        let tinter = UIView() // tintColor gets adjusted, so apply same with this
        view.textColorName = "not a color name"
        tinter.tintColor = .electric
        XCTAssertEqual(view.tintColor, tinter.tintColor)
        view.textColorName = "ash"
        tinter.tintColor = .ash
        XCTAssertEqual(view.tintColor, tinter.tintColor)
    }

    func testTextStyle() {
        let view = DynamicButton()
        view.textStyle = "not a real style"
        XCTAssertNotNil(view.titleLabel?.font)
        view.textStyle = "title"
        XCTAssertNotNil(view.titleLabel?.font)
        XCTAssertTrue(view.titleLabel!.adjustsFontForContentSizeCategory)
    }
}
