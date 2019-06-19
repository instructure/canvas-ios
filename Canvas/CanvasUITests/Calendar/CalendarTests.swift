//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

enum Calendar {
    static var todayButton: Element {
        return app.find(labelContaining: "Today")
    }

    static func text(containing text: String) -> Element {
        return app.find(labelContaining: text)
        //return XCUIElementWrapper(app.staticTexts[text].firstMatch)
    }
}

class CalendarTests: CanvasUITests {
    override var user: User? { return .student1 }

    func testCalendarTodayButton() {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthYear = formatter.string(from: Date()).uppercased()
        formatter.dateFormat = "d"
        let day = formatter.string(from: Date())

        // Calendar
        Dashboard.calendarTab.waitToExist()
        Dashboard.calendarTab.tap()
        app.swipeDown()
        app.swipeDown()
        XCTAssertFalse(Calendar.text(containing: monthYear).exists)
        Calendar.todayButton.tap()
        Calendar.text(containing: monthYear).waitToExist()
        Calendar.text(containing: day).waitToExist()
    }
}
