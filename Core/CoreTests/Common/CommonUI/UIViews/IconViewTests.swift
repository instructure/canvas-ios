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

class IconViewTests: XCTestCase {
    func testIconName() {
        let view = IconView()
        view.iconName = "not an icon name"
        XCTAssertNil(view.image)
        view.iconName = "instructureSolid"
        XCTAssertEqual(view.image, .instructureSolid)
    }

    func testIconColorName() {
        let view = IconView()
        let tinter = UIView() // tintColor gets adjusted, so apply same with this
        view.iconColorName = "not a color name"
        tinter.tintColor = .textInfo
        XCTAssertEqual(view.tintColor, tinter.tintColor)
        view.iconColorName = "primary"
        tinter.tintColor = Brand.shared.primary
        XCTAssertEqual(view.tintColor.hexString, tinter.tintColor.hexString)
    }
}
