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

import XCTest
@testable import Teacher

class SpeedGraderLandscapeSplitLayoutViewModelTests: XCTestCase {
    var testee: SpeedGraderLandscapeSplitLayoutViewModel!

    override func setUp() {
        super.setUp()
        testee = SpeedGraderLandscapeSplitLayoutViewModel()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func test_tappingDragIcon_togglesBetweenFullScreen_andCustomState() {
        let screenWidth: CGFloat = 1200
        testee.updateScreenWidth(screenWidth)

        // WHEN - Drag to custom size
        testee.didUpdateDragGesturePosition(horizontalTranslation: -100)
        testee.didEndDragGesture()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, (2 * screenWidth) / 3 - 100)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3 + 100)

        // WHEN
        testee.didTapDragIcon()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, screenWidth)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)
        XCTAssertEqual(testee.isRightColumnHidden, true)
        XCTAssertEqual(testee.dragIconA11yHint, "Double tap to open drawer")
        XCTAssertEqual(testee.dragIconA11yValue, "Closed")
        XCTAssertEqual(testee.dragIconRotation, .degrees(-180))

        // WHEN
        testee.didTapDragIcon()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, (2 * screenWidth) / 3 - 100)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3 + 100)
        XCTAssertEqual(testee.isRightColumnHidden, false)
        XCTAssertEqual(testee.dragIconA11yHint, "Double tap to close drawer")
        XCTAssertEqual(testee.dragIconA11yValue, "Open")
        XCTAssertEqual(testee.dragIconRotation, .degrees(0))
    }

    func test_dragToNearScreenEdge_snapsToFullScreen() {
        let screenWidth: CGFloat = 1200
        testee.updateScreenWidth(screenWidth)

        // WHEN
        testee.didUpdateDragGesturePosition(horizontalTranslation: 300)

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, 1100)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)

        // WHEN
        testee.didEndDragGesture()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, screenWidth)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)
    }

    func test_dragToLargerThanMaximumSize_snapsToMaximumSize() {
        let screenWidth: CGFloat = 1200
        testee.updateScreenWidth(screenWidth)

        // WHEN
        testee.didUpdateDragGesturePosition(horizontalTranslation: 100)

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, 900)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)

        // WHEN
        testee.didEndDragGesture()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, (2 * screenWidth) / 3)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)
    }

    func test_dragToSmallerThanMinimumSize_snapsToMinimumSize() {
        let screenWidth: CGFloat = 1200
        testee.updateScreenWidth(screenWidth)

        // WHEN
        testee.didUpdateDragGesturePosition(horizontalTranslation: -700)
        testee.didEndDragGesture()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, screenWidth / 3)
        XCTAssertEqual(testee.rightColumnWidth, (2 * screenWidth) / 3)
    }
}
