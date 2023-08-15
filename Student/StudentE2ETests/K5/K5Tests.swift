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

class K5Tests: K5E2ETestCase {
    typealias Helper = K5Helper

    func testK5Homeroom() {
        // MARK: Seed the usual stuff with a calendar event
        let student = seeder.createK5User()
        let homeroom = seeder.createK5Course()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: homeroom)
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, check elements
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        let homeroomButton = Helper.homeroom.waitUntil(.visible)
        let scheduleButton = Helper.schedule.waitUntil(.visible)
        let gradesButton = Helper.grades.waitUntil(.visible)
        let resourcesButton = Helper.resources.waitUntil(.visible)
        let importantDatesButton = Helper.importantDates.waitUntil(.visible)
        XCTAssertTrue(homeroomButton.actionUntilElementCondition(action: .swipeLeft, condition: .visible))
        XCTAssertTrue(scheduleButton.actionUntilElementCondition(action: .swipeLeft, condition: .visible))
        XCTAssertTrue(gradesButton.actionUntilElementCondition(action: .swipeLeft, condition: .visible))
        XCTAssertTrue(resourcesButton.actionUntilElementCondition(action: .swipeLeft, condition: .visible))
        XCTAssertTrue(importantDatesButton.actionUntilElementCondition(action: .swipeLeft, condition: .visible))
    }
}
