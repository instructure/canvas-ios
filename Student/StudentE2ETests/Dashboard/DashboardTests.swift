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

class DashboardTests: E2ETestCase {
    typealias Helper = DashboardHelper
    typealias CourseInvitations = Helper.CourseInvitations
    typealias AccountNotifications = Helper.AccountNotifications

    func testDashboard() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course1 = seeder.createCourse()
        let student = users[0]

        // MARK: Check for empty dashboard
        logInDSUser(student)
        let noCoursesLabel = app.find(label: "No Courses").waitUntil(.visible)
        XCTAssertTrue(noCoursesLabel.isVisible)

        // MARK: Check for course1
        seeder.enrollStudent(student, in: course1)
        pullToRefresh()
        let courseCard1 = Helper.courseCard(course: course1).waitUntil(.visible)
        XCTAssertTrue(courseCard1.isVisible)

        // MARK: Check for course2
        let course2 = seeder.createCourse()
        seeder.enrollStudent(student, in: course2)
        pullToRefresh()
        let courseCard2 = Helper.courseCard(course: course2).waitUntil(.visible)
        XCTAssertTrue(courseCard2.isVisible)

        // MARK: Select a favorite course and check for dashboard updating
        let dashboardEditButton = Helper.editButton.waitUntil(.visible)
        XCTAssertTrue(dashboardEditButton.isVisible)

        dashboardEditButton.hit()
        Helper.toggleFavorite(course: course2)
        let navBarBackButton = Helper.backButton.waitUntil(.visible)
        XCTAssertTrue(navBarBackButton.isVisible)

        navBarBackButton.hit()
        pullToRefresh()
        XCTAssertTrue(courseCard2.waitUntil(.visible).isVisible)
        XCTAssertFalse(courseCard1.waitUntil(.visible).isVisible)
    }

    func testAnnouncementBelowInvite() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()

        // MARK: Check for empty dashboard
        logInDSUser(student)
        XCTAssertTrue(app.find(label: "No Courses").waitUntil(.visible).isVisible)

        // MARK: Create an enrollment and an announcement
        let enrollment = seeder.enrollStudent(student, in: course, state: .invited)
        let announcement = AnnouncementsHelper.postAccountNotification()
        Helper.pullToRefresh()

        // MARK: Check visibility and order of the enrollment and the announcement
        let courseAcceptButton = CourseInvitations.acceptButton(enrollment: enrollment).waitUntil(.visible)
        XCTAssertTrue(courseAcceptButton.isVisible)

        let notificationToggleButton = AccountNotifications.toggleButton(notification: announcement)
            .waitUntil(.visible)
        XCTAssertTrue(notificationToggleButton.isVisible)
        XCTAssertLessThan(courseAcceptButton.frame.maxY, notificationToggleButton.frame.minY)

        notificationToggleButton.hit()
        AccountNotifications.dismissButton(notification: announcement).hit()
    }

    func testNavigateToDashboard() {
        // MARK: Seed the usual stuff and a front page for the course
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        Helper.createFrontPageForCourse(course: course)

        // MARK: Get the user logged in and navigate to the course
        logInDSUser(student)
        var courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)
        courseCard.hit()

        // MARK: Navigate to pages of course and open front page
        CourseDetailsHelper.cell(type: .pages).hit()
        PagesHelper.frontPage.hit()

        // MARK: Tap dashboard tab and check visibility of course card and label
        Helper.TabBar.dashboardTab.hit()
        let coursesLabel = Helper.coursesLabel.waitUntil(.visible)
        courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(coursesLabel.isVisible)
        XCTAssertTrue(courseCard.isVisible)
    }

    func testCourseCardInfo() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in and check visibility and label of course
        logInDSUser(student)
        let courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)
        XCTAssertTrue(courseCard.label.contains(course.name))
    }

    func testDashboardEditButtonDisplaysCorrectCourses() {
        // MARK: Seed the usual stuff with 7 courses and student enrolled in them with all 7 different states
        let student = seeder.createUser()
        let courses = Helper.createCourses(number: 7)
        seeder.enrollStudent(student, in: courses[0], state: .active)
        seeder.enrollStudent(student, in: courses[1], state: .invited)
        seeder.enrollStudent(student, in: courses[2], state: .completed)
        seeder.enrollStudent(student, in: courses[3], state: .creation_pending)
        seeder.enrollStudent(student, in: courses[4], state: .deleted)
        seeder.enrollStudent(student, in: courses[5], state: .inactive)
        seeder.enrollStudent(student, in: courses[6], state: .rejected)

        // MARK: Get the user logged in and check visibility and label of courses
        logInDSUser(student)
        var courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard1.label.contains(courses[0].name))

        var courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseCard2.label.contains(courses[1].name))

        // MARK: Tap edit button
        Helper.editButton.hit()

        // MARK: Completed, Active, Invited courses should be listed
        courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard1.label.contains(courses[0].name))

        courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseCard2.label.contains(courses[1].name))

        let courseCard3 = Helper.courseCard(course: courses[2]).waitUntil(.visible)
        XCTAssertTrue(courseCard3.isVisible)
        XCTAssertTrue(courseCard3.label.contains(courses[2].name))

        // MARK: Creation Pending, Deleted, Inactive, Rejected should not be listed
        let courseCard4 = Helper.courseCard(course: courses[3]).waitUntil(.vanish)
        XCTAssertTrue(courseCard4.isVanished)
        let courseCard5 = Helper.courseCard(course: courses[4]).waitUntil(.vanish)
        XCTAssertTrue(courseCard5.isVanished)
        let courseCard6 = Helper.courseCard(course: courses[5]).waitUntil(.vanish)
        XCTAssertTrue(courseCard6.isVanished)
        let courseCard7 = Helper.courseCard(course: courses[6]).waitUntil(.vanish)
        XCTAssertTrue(courseCard7.isVanished)
    }

    func testCourseCardGrades() {
        // MARK: Seed the usual stuff with a graded assignment
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let pointsPossible = "10"
        let totalGrade = "100%"
        seeder.enrollStudent(student, in: course)

        let assignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: Float(pointsPossible), gradingType: .percent)
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)
        GradesHelper.gradeAssignment(grade: pointsPossible, course: course, assignment: assignment, user: student)

        // MARK: Get the user logged in, check course card
        logInDSUser(student)
        var courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Check visibility of Dashboard Settings button
        var dashboardSettingsButton = Helper.dashboardSettings.waitUntil(.visible)
        XCTAssertTrue(dashboardSettingsButton.isVisible)

        // MARK: Tap Dashboard Settings button then check visibility and value of Show Grade toggle
        dashboardSettingsButton.hit()
        var showGradeToggle = Helper.dashboardSettingsShowGradeToggle.waitUntil(.visible)
        XCTAssertTrue(showGradeToggle.isVisible)
        XCTAssertTrue(showGradeToggle.hasValue(value: "0"))

        // MARK: Tap Show Grade toggle and check value again
        showGradeToggle.forceTap()
        XCTAssertTrue(showGradeToggle.hasValue(value: "1"))

        // MARK: Tap Done button then check visibility of course again
        var doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)

        doneButton.hit()

        // MARK: Check grade on Course Card label
        courseCard.waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        let courseCardGradeLabel = DashboardHelper.courseCardGradeLabel(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCardGradeLabel.isVisible)
        XCTAssertTrue(courseCardGradeLabel.actionUntilElementCondition(action: .pullToRefresh, condition: .label(expected: totalGrade)))

        // MARK: Unselect Show Grades toggle then check Course Card label again
        dashboardSettingsButton = Helper.dashboardSettings.waitUntil(.visible)
        XCTAssertTrue(dashboardSettingsButton.isVisible)

        dashboardSettingsButton.hit()
        showGradeToggle = Helper.dashboardSettingsShowGradeToggle.waitUntil(.visible)
        XCTAssertTrue(showGradeToggle.isVisible)

        showGradeToggle.forceTap()
        doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)

        doneButton.hit()
        courseCard.waitUntil(.visible)
        courseCardGradeLabel.waitUntil(.vanish)
        XCTAssertTrue(courseCard.isVisible)
        XCTAssertTrue(courseCardGradeLabel.isVanished)
    }
}
