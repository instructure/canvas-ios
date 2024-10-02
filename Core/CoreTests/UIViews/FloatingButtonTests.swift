//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class FloatingButtonTests: XCTestCase {
    func testBackgroundColorName() {
        let view = FloatingButton()
        view.backgroundColorName = "not a color name"
        XCTAssertEqual(view.backgroundColor, .backgroundInfo)
        view.backgroundColorName = "buttonSecondaryBackground"
        XCTAssertEqual(view.backgroundColor!.hexString, Brand.shared.buttonSecondaryBackground.hexString)
    }

    func testIconName() {
        let view = FloatingButton()
        view.iconName = "not an icon name"
        XCTAssertNil(view.image(for: .normal))
        view.iconName = "instructureSolid"
        XCTAssertEqual(view.image(for: .normal), .instructureSolid)
    }

    func testIconColorName() {
        let view = FloatingButton()
        let tinter = UIView() // tintColor gets adjusted, so apply same with this
        view.iconColorName = "not a color name"
        tinter.tintColor = .textLightest.variantForLightMode
        XCTAssertEqual(view.tintColor, tinter.tintColor)
        view.iconColorName = "buttonSecondaryText"
        tinter.tintColor = Brand.shared.buttonSecondaryText
        XCTAssertEqual(view.tintColor.hexString, tinter.tintColor.hexString)
    }
}
