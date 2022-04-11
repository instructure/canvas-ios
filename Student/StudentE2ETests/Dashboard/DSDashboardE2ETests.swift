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

class DSDashboardE2ETests: E2ETestCase {
    func testDashboard() {
        let users = seeder.createUsers(1)
        let course1 = seeder.createCourse()
        let student = users[0]

        // Check for empty dashboard
        logInDSUser(student)
        app.find(label:"No Courses").waitToExist()

        // Check for course1
        seeder.enrollStudent(student, in: course1)
        pullToRefresh()
        Dashboard.courseCard(id: course1.id).waitToExist()

        // Check for course2
        let course2 = seeder.createCourse()
        seeder.enrollStudent(student, in: course2)
        pullToRefresh()
        Dashboard.courseCard(id: course2.id).waitToExist()

        // Select a favorite course and check for dashboard updating
        Dashboard.editButton.tap()
        DashboardEdit.toggleFavorite(id: course2.id)
        NavBar.backButton.tap()
        pullToRefresh()
        XCTAssertTrue(Dashboard.courseCard(id: course2.id).exists())
        XCTAssertFalse(Dashboard.courseCard(id: course1.id).exists())
    }
}
