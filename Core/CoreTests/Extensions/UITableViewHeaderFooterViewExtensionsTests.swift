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
import UIKit
@testable import Core

class UITableViewHeaderFooterViewExtensionsTests: XCTestCase {
    let cell = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var borders: [UITableViewHeaderFooterView.BorderView] {
        cell.subviews.compactMap { $0 as? UITableViewHeaderFooterView.BorderView }
    }

    func testAddBorders() {
        XCTAssertEqual(borders.count, 0)
        cell.hasBorderSeparators = true
        XCTAssertEqual(borders.count, 2)
        cell.hasBorderSeparators = true
        XCTAssertEqual(borders.count, 2)
    }

    func testRemoveBorders() {
        cell.hasBorderSeparators = true
        XCTAssertEqual(borders.count, 2)
        cell.hasBorderSeparators = false
        XCTAssertEqual(borders.count, 0)
        cell.hasBorderSeparators = false
        XCTAssertEqual(borders.count, 0)
    }
}
