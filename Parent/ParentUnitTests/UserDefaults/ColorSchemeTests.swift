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
@testable import Parent
import TestsFoundation

class ColorSchemeTests: ParentTestCase {
    override func setUp() {
        super.setUp()
        env.userDefaults?.reset()
        ColorScheme.clear()
    }

    func testColor() {
        for scheme in ColorScheme.allCases {
            XCTAssertEqual(scheme.color, UIColor(named: scheme.rawValue, in: .parent, compatibleWith: nil))
        }
        XCTAssertEqual(ColorScheme.observer.color, UIColor(named: "observeeBlue", in: .parent, compatibleWith: nil))
    }

    func testObservee() {
        XCTAssertEqual(ColorScheme.observee("5"), ColorScheme.observeeBlue)
        XCTAssertEqual(ColorScheme.observee("54"), ColorScheme.observeePurple)
        XCTAssertEqual(ColorScheme.observee("1"), ColorScheme.observeePink)
        XCTAssertEqual(ColorScheme.observee("654"), ColorScheme.observeeRed)
        XCTAssertEqual(ColorScheme.observee("789"), ColorScheme.observeeOrange)
        XCTAssertEqual(ColorScheme.observee("~"), ColorScheme.observeeGreen)
        XCTAssertEqual(ColorScheme.observee("5"), ColorScheme.observeeBlue)
    }
}
