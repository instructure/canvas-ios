//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import TestsFoundation

class K5ScheduleE2ETests: K5UITestCase {
    func testK5Schedule() {
        setUpK5()

        XCTAssertTrue(K5Helper.courseCard(id: "21025").waitUntil(.visible).isVisible)
        XCTAssertTrue(K5Helper.schedule.waitUntil(.visible).isVisible)
        K5Helper.schedule.hit()
        XCTAssertTrue(K5Helper.todayHeader.waitUntil(.visible).isVisible)
        app.swipeLeft()
        XCTAssertFalse(K5Helper.todayHeader.waitUntil(.vanish).isVisible)
        XCTAssertTrue(K5Helper.todayButton.waitUntil(.visible).isVisible)
        app.swipeRight()
        XCTAssertTrue(K5Helper.todayHeader.waitUntil(.visible).isVisible)
        app.swipeRight()
        XCTAssertTrue(K5Helper.todayButton.waitUntil(.visible).isVisible)
        K5Helper.todayButton.hit()
        XCTAssertTrue(K5Helper.todayHeader.waitUntil(.visible).isVisible)
        XCTAssertTrue(K5Helper.previousWeekButton.waitUntil(.visible).isVisible)
        K5Helper.previousWeekButton.hit()
        XCTAssertTrue(K5Helper.previousWeekButton.waitUntil(.visible).isVisible)
        XCTAssertFalse(K5Helper.todayHeader.waitUntil(.vanish).isVisible)
        XCTAssertTrue(K5Helper.todayButton.waitUntil(.visible).isVisible)
        K5Helper.todayButton.hit()
        XCTAssertTrue(K5Helper.todayHeader.waitUntil(.visible).isVisible)
    }
}
