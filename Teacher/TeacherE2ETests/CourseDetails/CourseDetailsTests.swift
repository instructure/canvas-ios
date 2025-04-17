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
import XCTest

class CourseDetailsTests: E2ETestCase {
    func testCourseDetails() {
        // MARK: Seed the usual stuff with additional contents
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let module = ModulesHelper.createModule(course: course)
        AssignmentsHelper.createAssignment(course: course)
        AnnouncementsHelper.createAnnouncements(course: course)
        DiscussionsHelper.createDiscussion(course: course)
        PagesHelper.createPage(course: course)
        ModulesHelper.createModulePage(course: course, module: module)
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in and navigate to the course
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)
        courseCard.hit()

        // MARK: Check course details
        let titleLabel = CourseDetailsHelper.titleLabel.waitUntil(.visible)
        XCTAssertTrue(titleLabel.isVisible)
        XCTAssertEqual(titleLabel.label, course.name)

        let subtitleLabel = CourseDetailsHelper.subtitleLabel.waitUntil(.visible)
        XCTAssertTrue(subtitleLabel.isVisible)
        XCTAssertEqual(subtitleLabel.label, "Default Term")

        let announcementsButton = CourseDetailsHelper.cell(type: .announcements).waitUntil(.visible)
        XCTAssertTrue(announcementsButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let assignmentsButton = CourseDetailsHelper.cell(type: .assignments).waitUntil(.visible)
        XCTAssertTrue(assignmentsButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let discussionsButton = CourseDetailsHelper.cell(type: .discussions).waitUntil(.visible)
        XCTAssertTrue(discussionsButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let peopleButton = CourseDetailsHelper.cell(type: .people).waitUntil(.visible)
        XCTAssertTrue(peopleButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let pagesButton = CourseDetailsHelper.cell(type: .pages).waitUntil(.visible)
        XCTAssertTrue(pagesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let filesButton = CourseDetailsHelper.cell(type: .files).waitUntil(.visible)
        XCTAssertTrue(filesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus).waitUntil(.visible)
        XCTAssertTrue(syllabusButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let quizzesButton = CourseDetailsHelper.cell(type: .quizzes).waitUntil(.visible)
        XCTAssertTrue(quizzesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let modulesButton = CourseDetailsHelper.cell(type: .modules).waitUntil(.visible)
        XCTAssertTrue(modulesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let studioButton = CourseDetailsHelper.cell(type: .studio).waitUntil(.visible)
        XCTAssertTrue(studioButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let googleDriveButton = CourseDetailsHelper.cell(type: .googleDrive).waitUntil(.visible)
        XCTAssertTrue(googleDriveButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let studentViewButton = CourseDetailsHelper.cell(type: .studentView).waitUntil(.visible)
        XCTAssertTrue(studentViewButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))
    }
}
