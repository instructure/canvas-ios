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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(courseCard.isVisible)
        courseCard.tap()

        // MARK: Check course details
        let titleLabel = CourseDetailsHelper.titleLabel.waitUntil(condition: .visible)
        XCTAssertTrue(titleLabel.exists)
        XCTAssertEqual(titleLabel.label, course.name)

        let subtitleLabel = CourseDetailsHelper.subtitleLabel.waitUntil(condition: .visible)
        XCTAssertTrue(subtitleLabel.exists)
        XCTAssertEqual(subtitleLabel.label, "Default Term")

        let homeButton = CourseDetailsHelper.cell(type: .home)
        XCTAssertTrue(homeButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let announcementsButton = CourseDetailsHelper.cell(type: .announcements)
        XCTAssertTrue(announcementsButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let assignmentsButton = CourseDetailsHelper.cell(type: .assignments)
        XCTAssertTrue(assignmentsButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let discussionsButton = CourseDetailsHelper.cell(type: .discussions)
        XCTAssertTrue(discussionsButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let gradesButton = CourseDetailsHelper.cell(type: .grades)
        XCTAssertTrue(gradesButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let peopleButton = CourseDetailsHelper.cell(type: .people)
        XCTAssertTrue(peopleButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let pagesButton = CourseDetailsHelper.cell(type: .pages)
        XCTAssertTrue(pagesButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus)
        XCTAssertTrue(syllabusButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let modulesButton = CourseDetailsHelper.cell(type: .modules)
        XCTAssertTrue(modulesButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let bigBlueButtonButton = CourseDetailsHelper.cell(type: .bigBlueButton)
        XCTAssertTrue(bigBlueButtonButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let collaborationsButton = CourseDetailsHelper.cell(type: .collaborations)
        XCTAssertTrue(collaborationsButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))

        let googleDriveButton = CourseDetailsHelper.cell(type: .googleDrive)
        XCTAssertTrue(googleDriveButton.actionUntilElementCondition(action: .swipeUp, condition: .visible))
    }
}
