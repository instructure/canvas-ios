//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import XCTest

class FontAppearanceTests: XCTestCase {

    func testBarButtonItemFont() {
        FontAppearance.update()
        XCTAssertEqual(UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).titleTextAttributes(for: .normal)![.font] as! UIFont, UIFont.scaledNamedFont(.regular17))
    }

    func testSegmentedControlFont() {
        FontAppearance.update()
        XCTAssertEqual(UISegmentedControl.appearance().titleTextAttributes(for: .normal)![.font] as! UIFont, UIFont.scaledNamedFont(.regular13))
        XCTAssertEqual(UISegmentedControl.appearance().titleTextAttributes(for: .selected)![.font] as! UIFont, UIFont.scaledNamedFont(.bold13))
    }
}
