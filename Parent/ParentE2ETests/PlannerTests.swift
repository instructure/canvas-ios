//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import TestsFoundation
@testable import CoreUITests

class PlannerTests: CoreUITestCase {
    let calendar = Calendar.current
    let y = 2020
    let m = 3
    lazy var reference = DateComponents(calendar: .current, year: y, month: m, day: 1).date!

    override var experimentalFeatures: [ExperimentalFeature] { [.parentCalendar] }

    override func setUp() {
        super.setUp()
        Courses.course(id: "263").waitToExist()
        TabBar.calendarTab.tap()
        navigateToReference()
    }

    func navigateToReference() {
        if !PlannerCalendar.monthButton.isSelected {
            PlannerCalendar.monthButton.tap()
        }
        var shown = Date()
        while calendar.compare(shown, to: reference, toGranularity: .month) != .orderedSame {
            let isPast = calendar.compare(shown, to: reference, toGranularity: .month) == .orderedAscending
            let halfScreen = UIScreen.main.bounds.width / 2
            let daysCenter = PlannerCalendar.monthButton.relativeCoordinate(x: 0, y: 1)
                .withOffset(CGVector(dx: halfScreen, dy: 50))
            let dragTo = daysCenter.withOffset(CGVector(dx: isPast ? -halfScreen : halfScreen, dy: 0))
            daysCenter.press(forDuration: 0, thenDragTo: dragTo)
            shown = shown.addMonths(isPast ? 1 : -1)
        }
        PlannerCalendar.dayButton(for: reference).tap()
    }

    func testActivityDots() {
        XCTAssert(PlannerCalendar.dayButton(year: y, month: m, day: 1).label().contains("1, \(y), 1 event"))
        XCTAssert(PlannerCalendar.dayButton(year: y, month: m, day: 2).label().contains("2, \(y), 2 events"))
        XCTAssert(PlannerCalendar.dayButton(year: y, month: m, day: 3).label().contains("3, \(y), 3 events"))
        XCTAssert(PlannerCalendar.dayButton(year: y, month: m, day: 4).label().contains("4, \(y), 0 events"))
    }

    func testList() {
        PlannerList.event(id: "2233").waitToExist()
        PlannerCalendar.dayButton(year: y, month: m, day: 2).tap()
        PlannerList.event(id: "2234").waitToExist() // second
        XCTAssert(PlannerList.event(id: "2235").exists()) // second 2
        PlannerCalendar.dayButton(year: y, month: m, day: 4).tap()
        XCTAssertEqual(PlannerList.emptyTitle.label(), "No Assignments")
        XCTAssertEqual(PlannerList.emptyLabel.label(), "It looks like assignments haven’t been created in this space yet.")
    }
}
