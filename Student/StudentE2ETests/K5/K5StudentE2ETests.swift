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

class K5StudentE2ETests: K5UITestCase {
    func testStudentK5() {
        setUpK5()
        XCTAssertTrue(K5Helper.courseCard(id: "21025").waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(K5Helper.accountNotificationString.waitUntil(condition: .visible).isVisible)

        K5Helper.courseCard(id: "21025").hit()
        XCTAssertTrue(K5Helper.homeTab.waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(K5Helper.scheduleTab.waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(K5Helper.gradesTab.waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(K5Helper.modulesTab.waitUntil(condition: .visible).isVisible)

        K5Helper.gradesTab.hit()
        XCTAssertTrue(K5Helper.emptyGradesForCourse.waitUntil(condition: .visible).isVisible)

        K5Helper.modulesTab.hit()
        XCTAssertTrue(K5Helper.emptyPage.waitUntil(condition: .visible).isVisible)
    }
}
