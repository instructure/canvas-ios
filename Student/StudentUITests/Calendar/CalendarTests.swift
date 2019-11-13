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
import TestsFoundation
@testable import CoreUITests

enum CalendarElements {
    static var todayButton: Element {
        return app.find(labelContaining: "Today")
    }

    static func text(containing text: String) -> Element {
        return app.find(labelContaining: text)
    }
}

class CalendarTests: CoreUITestCase {
    func testCalendarTodayButton() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthYear = formatter.string(from: Date()).uppercased()
        formatter.dateFormat = "d"
        let day = formatter.string(from: Date())

        TabBar.calendarTab.tap()
        app.swipeDown()
        app.swipeDown()
        XCTAssertFalse(CalendarElements.text(containing: monthYear).exists)
        CalendarElements.todayButton.tap()
        CalendarElements.text(containing: monthYear).waitToExist()
        CalendarElements.text(containing: day).waitToExist()
    }
}
