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

import TestsFoundation

class DSDashboardTest: E2ETestCase {
    func testDashboard() {
        let users = seeder.createUsers(1)
        let course1 = seeder.createCourse()
        let teacher = users[0]
        seeder.enrollTeacher(teacher, in: course1)

        // Let's seed and check coursecard one-by-one
        logInDSUser(teacher)
        DashboardHelper.courseCard(course: course1).waitUntil(.visible)

        let course2 = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course2)
        pullToRefresh()
        XCTAssertTrue(DashboardHelper.courseCard(course: course1).waitUntil(.visible).isVisible)
        XCTAssertTrue(DashboardHelper.courseCard(course: course2).waitUntil(.visible).isVisible)

        let course3 = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course3)
        pullToRefresh()
        XCTAssertTrue(DashboardHelper.courseCard(course: course1).waitUntil(.visible).isVisible)
        XCTAssertTrue(DashboardHelper.courseCard(course: course2).waitUntil(.visible).isVisible)
        XCTAssertTrue(DashboardHelper.courseCard(course: course3).waitUntil(.visible).isVisible)

        // Check if only favorited card is shown
        DashboardHelper.editButton.hit()
        DashboardHelper.toggleFavorite(course: course1)
        DashboardHelper.backButton.hit()
        pullToRefresh()
        XCTAssertTrue(DashboardHelper.courseCard(course: course1).waitUntil(.visible).isVisible)
        XCTAssertFalse(DashboardHelper.courseCard(course: course2).waitUntil(.visible).isVisible)
        XCTAssertFalse(DashboardHelper.courseCard(course: course3).waitUntil(.visible).isVisible)
    }
}
