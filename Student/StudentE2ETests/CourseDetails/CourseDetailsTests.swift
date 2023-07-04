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
        // MARK: Seed the usual stuff with additional contents
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let module = ModulesHelper.createModule(course: course)
        AssignmentsHelper.createAssignment(course: course)
        AnnouncementsHelper.createAnnouncements(course: course)
        DiscussionsHelper.createDiscussion(course: course)
        PagesHelper.createPage(course: course)
        ModulesHelper.createModulePage(course: course, module: module)
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in and navigate to the course
        logInDSUser(student)
        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
        courseCard.tap()

        // MARK: Check course details
        let titleLabel = CourseDetailsHelper.titleLabel.waitToExist()
        XCTAssertTrue(titleLabel.exists)
        XCTAssertEqual(titleLabel.label(), course.name)

        let subtitleLabel = CourseDetailsHelper.subtitleLabel.waitToExist()
        XCTAssertTrue(subtitleLabel.exists)
        XCTAssertEqual(subtitleLabel.label(), "Default Term")

        let homeButton = CourseDetailsHelper.cell(type: .home).waitToExist()
        XCTAssertTrue(homeButton.isVisible)

        let announcementsButton = CourseDetailsHelper.cell(type: .announcements).waitToExist()
        XCTAssertTrue(announcementsButton.isVisible)

        let assignmentsButton = CourseDetailsHelper.cell(type: .assignments).waitToExist()
        XCTAssertTrue(assignmentsButton.isVisible)

        let discussionsButton = CourseDetailsHelper.cell(type: .discussions).waitToExist()
        XCTAssertTrue(discussionsButton.isVisible)

        let gradesButton = CourseDetailsHelper.cell(type: .grades).waitToExist()
        XCTAssertTrue(gradesButton.isVisible)

        let peopleButton = CourseDetailsHelper.cell(type: .people).waitToExist()
        XCTAssertTrue(peopleButton.isVisible)

        let pagesButton = CourseDetailsHelper.cell(type: .pages).waitToExist()
        XCTAssertTrue(pagesButton.swipeUntilVisible(direction: .up))

        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus).waitToExist()
        XCTAssertTrue(syllabusButton.swipeUntilVisible(direction: .up))

        let modulesButton = CourseDetailsHelper.cell(type: .modules).waitToExist()
        XCTAssertTrue(modulesButton.swipeUntilVisible(direction: .up))

        let bigBlueButtonButton = CourseDetailsHelper.cell(type: .bigBlueButton).waitToExist()
        XCTAssertTrue(bigBlueButtonButton.swipeUntilVisible(direction: .up))

        let collaborationsButton = CourseDetailsHelper.cell(type: .collaborations).waitToExist()
        XCTAssertTrue(collaborationsButton.swipeUntilVisible(direction: .up))

        let googleDriveButton = CourseDetailsHelper.cell(type: .googleDrive).waitToExist()
        XCTAssertTrue(googleDriveButton.swipeUntilVisible(direction: .up))
    }
}
