//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Core
import XCTest

class CGSizeExtensionsTests: CoreTestCase {

    func test_isZero() {
        XCTAssertTrue(CGSize.zero.isZero)
        XCTAssertTrue(CGSize(width: 0, height: 0).isZero)

        XCTAssertFalse(CGSize(width: 1, height: 1).isZero)
    }

    func test_isSwipingLeft() {
        XCTAssertTrue(CGSize(width: -10, height: 0).isSwipingLeft)
        XCTAssertTrue(CGSize(width: -1, height: 5).isSwipingLeft)
        XCTAssertTrue(CGSize(width: -100, height: -50).isSwipingLeft)

        XCTAssertFalse(CGSize(width: 0, height: 0).isSwipingLeft)
        XCTAssertFalse(CGSize(width: 10, height: 0).isSwipingLeft)
        XCTAssertFalse(CGSize(width: 5, height: -3).isSwipingLeft)
    }

    func test_isHorizontalSwipe() {
        XCTAssertTrue(CGSize(width: 10, height: 5).isHorizontalSwipe)
        XCTAssertTrue(CGSize(width: -10, height: 5).isHorizontalSwipe)
        XCTAssertTrue(CGSize(width: 10, height: -5).isHorizontalSwipe)
        XCTAssertTrue(CGSize(width: -10, height: -5).isHorizontalSwipe)
        XCTAssertTrue(CGSize(width: 50, height: 0).isHorizontalSwipe)

        XCTAssertFalse(CGSize(width: 5, height: 10).isHorizontalSwipe)
        XCTAssertFalse(CGSize(width: -5, height: 10).isHorizontalSwipe)
        XCTAssertFalse(CGSize(width: 5, height: -10).isHorizontalSwipe)
        XCTAssertFalse(CGSize(width: 0, height: 50).isHorizontalSwipe)
        XCTAssertFalse(CGSize(width: 0, height: 0).isHorizontalSwipe)
    }
}
