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

@testable import Core
import XCTest
import TestsFoundation

class CourseDetailsHeaderViewModelTests: CoreTestCase {

    func testProperties() {
        api.mock(GetUserSettings(userID: "self"), value: .make(hide_dashcard_color_overlays: true))
        let course = Course.save(.make(term: .make()), in: databaseClient)
        course.contextColor = ContextColor.save(.init(custom_colors: ["1": "#FF0000"]), in: databaseClient)[0]

        let testee = CourseDetailsHeaderViewModel()
        testee.viewDidAppear()
        testee.courseUpdated(course)

        XCTAssertTrue(testee.hideColorOverlay)
        XCTAssertEqual(testee.verticalOffset, 0)
        XCTAssertEqual(testee.imageOpacity, 0.4)
        XCTAssertEqual(testee.titleOpacity, 1)
        XCTAssertEqual(testee.courseName, "Course One")
        XCTAssertEqual(testee.courseColor.hexString, UIColor(hexString: "#FF0000")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(testee.termName, "Term One")
        XCTAssertEqual(testee.imageURL, nil)
    }

    func testHeaderVisibility() {
        let testee = CourseDetailsHeaderViewModel()
        // header would take half of the screen's height
        XCTAssertEqual(testee.shouldShowHeader(for: 2 * testee.height), false)
        // there's more space for cells than what the header blocks
        XCTAssertEqual(testee.shouldShowHeader(for: 2 * testee.height + 1), true)
    }

    func testPullToRefreshScrollCalculation() {
        let testee = CourseDetailsHeaderViewModel()
        // pull down as many points as high the header is
        testee.scrollPositionChanged([.init(viewId: 0, bounds: .init(x: 0, y: testee.height, width: 0, height: 0))])

        XCTAssertEqual(testee.verticalOffset, testee.height)
        XCTAssertEqual(testee.imageOpacity, 0.4)
        XCTAssertEqual(testee.titleOpacity, 1)
    }

    func testScrollUpToCellsCalculation() {
        let testee = CourseDetailsHeaderViewModel()
        // scroll up as many points as high the header is
        let scrollOffset = -testee.height
        testee.scrollPositionChanged([.init(viewId: 0, bounds: .init(x: 0, y: scrollOffset, width: 0, height: 0))])

        // parallax scrolls only half the amount
        XCTAssertEqual(testee.verticalOffset, scrollOffset / 2)
        XCTAssertEqual(testee.imageOpacity, 0)
        XCTAssertEqual(testee.titleOpacity, 0)
    }
}
