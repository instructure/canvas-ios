//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import Core
import SwiftUI
import XCTest

class FontExtensionTests: XCTestCase {

    func testFonts() {
        XCTAssertEqual(Font.regular10, Font(UIFont.scaledNamedFont(.regular10)))
        XCTAssertEqual(Font.regular11Monodigit, Font(UIFont.scaledNamedFont(.regular11Monodigit)))
        XCTAssertEqual(Font.regular12, Font(UIFont.scaledNamedFont(.regular12)))
        XCTAssertEqual(Font.regular13, Font(UIFont.scaledNamedFont(.regular13)))
        XCTAssertEqual(Font.regular14, Font(UIFont.scaledNamedFont(.regular14)))
        XCTAssertEqual(Font.regular14Italic, Font(UIFont.scaledNamedFont(.regular14Italic)))
        XCTAssertEqual(Font.regular16, Font(UIFont.scaledNamedFont(.regular16)))
        XCTAssertEqual(Font.regular17, Font(UIFont.scaledNamedFont(.regular17)))
        XCTAssertEqual(Font.regular20, Font(UIFont.scaledNamedFont(.regular20)))
        XCTAssertEqual(Font.regular23, Font(UIFont.scaledNamedFont(.regular23)))
        XCTAssertEqual(Font.regular24, Font(UIFont.scaledNamedFont(.regular24)))
        XCTAssertEqual(Font.regular20Monodigit, Font(UIFont.scaledNamedFont(.regular20Monodigit)))
        XCTAssertEqual(Font.regular30, Font(UIFont.scaledNamedFont(.regular30)))

        XCTAssertEqual(Font.medium10, Font(UIFont.scaledNamedFont(.medium10)))
        XCTAssertEqual(Font.medium12, Font(UIFont.scaledNamedFont(.medium12)))
        XCTAssertEqual(Font.medium14, Font(UIFont.scaledNamedFont(.medium14)))
        XCTAssertEqual(Font.medium16, Font(UIFont.scaledNamedFont(.medium16)))
        XCTAssertEqual(Font.medium20, Font(UIFont.scaledNamedFont(.medium20)))

        XCTAssertEqual(Font.semibold11, Font(UIFont.scaledNamedFont(.semibold11)))
        XCTAssertEqual(Font.semibold12, Font(UIFont.scaledNamedFont(.semibold12)))
        XCTAssertEqual(Font.semibold14, Font(UIFont.scaledNamedFont(.semibold14)))
        XCTAssertEqual(Font.semibold16, Font(UIFont.scaledNamedFont(.semibold16)))
        XCTAssertEqual(Font.semibold17, Font(UIFont.scaledNamedFont(.semibold17)))
        XCTAssertEqual(Font.semibold16Italic, Font(UIFont.scaledNamedFont(.semibold16Italic)))
        XCTAssertEqual(Font.semibold18, Font(UIFont.scaledNamedFont(.semibold18)))
        XCTAssertEqual(Font.semibold20, Font(UIFont.scaledNamedFont(.semibold20)))
        XCTAssertEqual(Font.semibold22, Font(UIFont.scaledNamedFont(.semibold22)))
        XCTAssertEqual(Font.semibold23, Font(UIFont.scaledNamedFont(.semibold23)))

        XCTAssertEqual(Font.bold10, Font(UIFont.scaledNamedFont(.bold10)))
        XCTAssertEqual(Font.bold11, Font(UIFont.scaledNamedFont(.bold11)))
        XCTAssertEqual(Font.bold13, Font(UIFont.scaledNamedFont(.bold13)))
        XCTAssertEqual(Font.bold14, Font(UIFont.scaledNamedFont(.bold14)))
        XCTAssertEqual(Font.bold15, Font(UIFont.scaledNamedFont(.bold15)))
        XCTAssertEqual(Font.bold16, Font(UIFont.scaledNamedFont(.bold16)))
        XCTAssertEqual(Font.bold17, Font(UIFont.scaledNamedFont(.bold17)))
        XCTAssertEqual(Font.bold20, Font(UIFont.scaledNamedFont(.bold20)))
        XCTAssertEqual(Font.bold24, Font(UIFont.scaledNamedFont(.bold24)))
        XCTAssertEqual(Font.bold34, Font(UIFont.scaledNamedFont(.bold34)))

        XCTAssertEqual(Font.heavy24, Font(UIFont.scaledNamedFont(.heavy24)))
    }
}
