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

class PlannerTests: CoreUITestCase {
    let calendar = Calendar.current
    let y = 2023
    let m = 3
    lazy var reference = DateComponents(calendar: .current, year: y, month: m, day: 1).date!

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
            if isPast {
                PlannerCalendar.dayButton(for: shown).waitToExist()
                app.swipeLeft()
            } else {
                PlannerCalendar.dayButton(for: shown).waitToExist()
                app.swipeRight()
            }
            shown = shown.addMonths(isPast ? 1 : -1)
        }
        PlannerCalendar.dayButton(for: reference).tap()
    }

    func testPlanner() {
        PlannerList.event(id: "2904").waitToExist()
        XCTAssertEqual(PlannerCalendar.dayButton(year: y, month: m, day: 1).label(), "March 1, \(y), 1 event")

        PlannerList.event(id: "2904").tap()
        app.find(label: "first").waitToExist()
        app.find(label: "Instructure SLC").waitToExist()
        app.find(label: "6330 S 3000 E Salt Lake City, UT 84121").waitToExist()
        NavBar.backButton.tap()

        PlannerCalendar.dayButton(year: y, month: m, day: 2).tap()
        PlannerList.event(id: "2905").waitToExist() // second
        XCTAssertEqual(PlannerCalendar.dayButton(year: y, month: m, day: 2).label(), "March 2, \(y), 2 events")

        PlannerList.event(id: "2905").tap()
        app.find(label: "second").waitToExist()
        NavBar.backButton.tap()

        PlannerCalendar.dayButton(year: y, month: m, day: 3).tap()
        PlannerList.event(id: "assignment_23334").waitToExist() // third
        XCTAssertEqual(PlannerCalendar.dayButton(year: y, month: m, day: 3).label(), "March 3, \(y), 1 event")

        PlannerList.event(id: "assignment_23334").tap()
        app.find(label: "Planner Assignment").waitToExist()
        NavBar.backButton.tap()

        PlannerCalendar.dayButton(year: y, month: m, day: 4).tap()
        PlannerList.emptyTitle.waitToExist()
        XCTAssertEqual(PlannerList.emptyTitle.label(), "No Events Today!")
        XCTAssertEqual(PlannerList.emptyLabel.label(), "It looks like a great day to rest, relax, and recharge.")
        XCTAssertEqual(PlannerCalendar.dayButton(year: y, month: m, day: 4).label(), "March 4, \(y), 0 events")
    }

    func testSwipes() {
        // Disabled test, passes locally but fails on bitrise. To re-enable it, right click on the test symbol and select enabled or edit NightlyTests.xctestplan
        PlannerCalendar.dayButton(year: y, month: m, day: 1).swipeLeft()
        PlannerCalendar.monthButton.tap() // collapse
        PlannerCalendar.dayButton(year: y, month: m, day: 15).waitToVanish()
        PlannerCalendar.dayButton(year: y, month: m + 1, day: 1).swipeLeft()
        PlannerCalendar.dayButton(year: y, month: m + 1, day: 8).swipeLeft()
        PlannerCalendar.dayButton(year: y, month: m + 1, day: 15).waitToExist()
        PlannerCalendar.monthButton.tap() // expand
        PlannerCalendar.dayButton(year: y, month: m + 1, day: 15).swipeRight()
        PlannerCalendar.dayButton(year: y, month: m, day: 15).swipeRight()
        PlannerCalendar.monthButton.tap() // collapse
        PlannerCalendar.dayButton(year: y, month: m - 1, day: 28).waitToVanish()
        PlannerCalendar.dayButton(year: y, month: m - 1, day: 15).waitToExist()
        PlannerCalendar.monthButton.tap() // expand
        PlannerCalendar.dayButton(year: y, month: m - 1, day: 15).swipeLeft()

        PlannerCalendar.dayButton(for: reference).tap()
        PlannerList.event(id: "2904").waitToExist()
        PlannerList.event(id: "2904").swipeRight()
        PlannerCalendar.dayButton(for: reference.addDays(-1)).waitToExist()
        XCTAssert(PlannerCalendar.dayButton(for: reference.addDays(-1)).isSelected)
        PlannerCalendar.monthButton.tap() // collapse
        PlannerList.emptyTitle.swipeDown() // pull to refresh
        PlannerList.emptyTitle.swipeLeft()
        PlannerList.event(id: "2904").swipeDown() // more pull to refresh
        PlannerCalendar.monthButton.tapUntil {
            PlannerCalendar.monthButton.isSelected
        } // expand

        PlannerCalendar.dayButton(year: y, month: m, day: 8).tap()
        PlannerCalendar.dayButton(year: y, month: m, day: 22).center
            .press(forDuration: 0, thenDragTo: PlannerCalendar.monthButton.center) // collapse
        PlannerCalendar.dayButton(year: y, month: m, day: 15).waitToVanish()
        PlannerCalendar.monthButton.center
            .press(forDuration: 0, thenDragTo: PlannerList.emptyTitle.center) // expand
        PlannerCalendar.dayButton(year: y, month: m, day: 15).waitToExist()
        PlannerList.emptyTitle.center.withOffset(CGVector(dx: 0, dy: -100))
            .press(forDuration: 0, thenDragTo: PlannerCalendar.monthButton.center) // collapse
        PlannerCalendar.dayButton(year: y, month: m, day: 15).waitToVanish()

        for _ in 0..<7 { PlannerList.emptyTitle.swipeLeft() }
        PlannerCalendar.dayButton(year: y, month: m, day: 8).waitToVanish()
        PlannerCalendar.dayButton(year: y, month: m, day: 15).waitToExist()
    }

    func testCalendarFilter() {
        PlannerCalendar.dayButton(year: y, month: m, day: 3).tap()
        PlannerCalendar.monthButton.tap() // collapse
        PlannerCalendar.filterButton.tap()
        XCTAssertEqual(PlannerFilter.headerLabel.label(), "Tap to select the courses you want to see on the calendar.")

        let assignments = { PlannerFilter.cell(section: 0, row: 1) }
        XCTAssertEqual(assignments().label(), "Assignments")
        XCTAssertEqual(assignments().isSelected, true)
        assignments().tap()
        assignments().waitToExist()
        XCTAssertEqual(assignments().isSelected, false)
        NavBar.backButton(label: "Done").tap()
        PlannerList.event(id: "assignment_23334").waitToVanish()
        PlannerCalendar.dayButton(year: y, month: m, day: 4).tap()
        PlannerCalendar.dayButton(year: y, month: m, day: 3).tap()
        PlannerCalendar.dayButton(year: y, month: m, day: 3).waitToExist()
        XCTAssertEqual(PlannerCalendar.dayButton(year: y, month: m, day: 3).label(), "March 3, \(y), 3 events")

        PlannerCalendar.filterButton.tap()
        XCTAssertEqual(assignments().isSelected, false)
        assignments().tap()
        assignments().waitToExist()
        XCTAssertEqual(assignments().isSelected, true)
        NavBar.backButton(label: "Done").tap()
        PlannerCalendar.dayButton(year: y, month: m, day: 4).tap()
        PlannerCalendar.dayButton(year: y, month: m, day: 3).tap()
        PlannerList.event(id: "assignment_23334").waitToExist()
        XCTAssertEqual(PlannerCalendar.dayButton(year: y, month: m, day: 3).label(), "March 3, \(y), 1 event")

        PlannerList.event(id: "assignment_23334").tap()
        app.find(label: "This exists just for testing the planner").waitToExist()
    }
}
