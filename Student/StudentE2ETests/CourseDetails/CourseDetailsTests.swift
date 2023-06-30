//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class CourseDetailsTests: E2ETestCase {
    func testCourseDetails() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in and navigate to the course
        logInDSUser(student)
        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
        courseCard.tap()

        // MARK: Check course details
        let homeButton = CourseDetailsHelper.cell(type: .home).waitToExist()
        XCTAssertTrue(homeButton.isVisible)

        let discussionsButton = CourseDetailsHelper.cell(type: .discussions).waitToExist()
        XCTAssertTrue(discussionsButton.isVisible)

        let gradesButton = CourseDetailsHelper.cell(type: .grades).waitToExist()
        XCTAssertTrue(gradesButton.isVisible)

        let peopleButton = CourseDetailsHelper.cell(type: .people).waitToExist()
        XCTAssertTrue(peopleButton.isVisible)

        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus).waitToExist()
        XCTAssertTrue(syllabusButton.isVisible)

        let bigBlueButtonButton = CourseDetailsHelper.cell(type: .bigBlueButton).waitToExist()
        XCTAssertTrue(bigBlueButtonButton.isVisible)

        let collaborationsButton = CourseDetailsHelper.cell(type: .collaborations).waitToExist()
        XCTAssertTrue(collaborationsButton.swipeUntilVisible(direction: .up))

        let googleDriveButton = CourseDetailsHelper.cell(type: .googleDrive).waitToExist()
        XCTAssertTrue(googleDriveButton.swipeUntilVisible(direction: .up))
    }
}
