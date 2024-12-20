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

class DynamicLabelTests: XCTestCase {
    func testTextColorName() {
        let view = DynamicLabel(frame: .zero)
        view.textColorName = "not a color name"
        XCTAssertEqual(view.textColor, UIColor.textDarkest)
        view.textColorName = "textInfo"
        XCTAssertEqual(view.textColor, UIColor.textInfo)
    }

    func testTextStyle() {
        let view = DynamicLabel(frame: .zero)
        view.textStyle = "not a real style"
        XCTAssertNotNil(view.font)
        view.textStyle = "title"
        XCTAssertNotNil(view.font)
        XCTAssertTrue(view.adjustsFontForContentSizeCategory)
    }
}
