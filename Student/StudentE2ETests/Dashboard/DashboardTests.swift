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
    func testDashboard() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course1 = seeder.createCourse()
        let student = users[0]

        // MARK: Check for empty dashboard
        logInDSUser(student)
        let noCoursesLabel = app.find(label: "No Courses").waitToExist()
        XCTAssertTrue(noCoursesLabel.isVisible)

        // MARK: Check for course1
        seeder.enrollStudent(student, in: course1)
        pullToRefresh()
        let courseCard1 = Dashboard.courseCard(id: course1.id).waitToExist()
        XCTAssertTrue(courseCard1.isVisible)

        // MARK: Check for course2
        let course2 = seeder.createCourse()
        seeder.enrollStudent(student, in: course2)
        pullToRefresh()
        let courseCard2 = Dashboard.courseCard(id: course2.id).waitToExist()
        XCTAssertTrue(courseCard2.isVisible)

        // MARK: Select a favorite course and check for dashboard updating
        let dashboardEditButton = Dashboard.editButton.waitToExist()
        XCTAssertTrue(dashboardEditButton.isVisible)

        dashboardEditButton.tap()
        DashboardEdit.toggleFavorite(id: course2.id)
        let navBarBackButton = NavBar.backButton.waitToExist()
        XCTAssertTrue(navBarBackButton.isVisible)

        navBarBackButton.tap()
        pullToRefresh()
        XCTAssertTrue(Dashboard.courseCard(id: course2.id).exists())
        XCTAssertFalse(Dashboard.courseCard(id: course1.id).exists())
    }

    func testAnnouncementBelowInvite() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()

        // MARK: Check for empty dashboard
        logInDSUser(student)
        app.find(label: "No Courses").waitToExist()

        // MARK: Create an enrollment and an announcement
        let enrollment = seeder.enrollStudent(student, in: course, state: .invited)
        let announcement = AnnouncementsHelper.postAccountNotification()
        BaseHelper.pullToRefresh()

        // MARK: Check visibility and order of the enrollment and the announcement
        let courseAcceptButton = CourseInvitation.acceptButton(id: enrollment.id).waitToExist()
        XCTAssertTrue(courseAcceptButton.isVisible)

        let notificationToggleButton = AccountNotifications.toggleButton(id: announcement.id).waitToExist()
        XCTAssertTrue(notificationToggleButton.isVisible)

        XCTAssertLessThan(courseAcceptButton.frame().maxY, notificationToggleButton.frame().minY)
    }

    func testNavigateToDashboard() {
        // MARK: Seed the usual stuff and a front page for the course
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        DashboardHelper.createFrontPageForCourse(course: course)

        // MARK: Get the user logged in and navigate to the course
        logInDSUser(student)
        var courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
        courseCard.tap()

        // MARK: Navigate to pages of course and open front page
        CourseNavigation.pages.tap()
        PageList.frontPage.tap()

        // MARK: Tap dashboard tab and check visibility of course card and label
        TabBar.dashboardTab.tap()
        let coursesLabel = Dashboard.coursesLabel.waitToExist()
        courseCard = Dashboard.courseCard(id: course.id).waitToExist()
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
        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
        XCTAssertTrue(courseCard.label().contains(course.name))
    }

    func testDashboardEditButtonDisplaysCorrectCourses() {
        // MARK: Seed the usual stuff with 7 courses and student enrolled in them with all 7 different states
        let student = seeder.createUser()
        let courses = DashboardHelper.createCourses(number: 7)
        seeder.enrollStudent(student, in: courses[0], state: .active)
        seeder.enrollStudent(student, in: courses[1], state: .invited)
        seeder.enrollStudent(student, in: courses[2], state: .completed)
        seeder.enrollStudent(student, in: courses[3], state: .creation_pending)
        seeder.enrollStudent(student, in: courses[4], state: .deleted)
        seeder.enrollStudent(student, in: courses[5], state: .inactive)
        seeder.enrollStudent(student, in: courses[6], state: .rejected)

        // MARK: Get the user logged in and check visibility and label of courses
        logInDSUser(student)
        var courseCard1 = Dashboard.courseCard(id: courses[0].id).waitToExist()
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard1.label().contains(courses[0].name))
        var courseCard2 = Dashboard.courseCard(id: courses[1].id).waitToExist()
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseCard2.label().contains(courses[1].name))

        // MARK: Tap edit button
        Dashboard.editButton.tap()

        // MARK: Completed, Active, Invited courses should be listed
        courseCard1 = Dashboard.courseCard(id: courses[0].id).waitToExist()
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard1.label().contains(courses[0].name))
        courseCard2 = Dashboard.courseCard(id: courses[1].id).waitToExist()
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseCard2.label().contains(courses[1].name))
        let courseCard3 = Dashboard.courseCard(id: courses[2].id).waitToExist()
        XCTAssertTrue(courseCard3.isVisible)
        XCTAssertTrue(courseCard3.label().contains(courses[2].name))

        // MARK: Creation Pending, Deleted, Inactive, Rejected should not be listed
        let courseCard4 = Dashboard.courseCard(id: courses[3].id).waitToVanish()
        XCTAssertFalse(courseCard4.isVisible)
        let courseCard5 = Dashboard.courseCard(id: courses[4].id).waitToVanish()
        XCTAssertFalse(courseCard5.isVisible)
        let courseCard6 = Dashboard.courseCard(id: courses[5].id).waitToVanish()
        XCTAssertFalse(courseCard6.isVisible)
        let courseCard7 = Dashboard.courseCard(id: courses[6].id).waitToVanish()
        XCTAssertFalse(courseCard7.isVisible)
    }

    func testCourseCardGrades() throws {
        try XCTSkipIf(true, "Works locally but fails on CI")

        // MARK: Seed the usual stuff with a graded assignment
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let assignment = GradesHelper.createAssignments(course: course, count: 1)
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignment)
        GradesHelper.gradeAssignments(grades: ["100"], course: course, assignments: assignment, user: student)

        // MARK: Get the user logged in and check visibility of course
        logInDSUser(student)
        var courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Check visibility of Dashboard Settings button
        var dashboardSettingsButton = DashboardHelper.dashboardSettings.waitToExist()
        XCTAssertTrue(dashboardSettingsButton.isVisible)

        // MARK: Tap Dashboard Settings button then check visibility and value of Show Grade toggle
        dashboardSettingsButton.tap()
        var showGradeToggle = DashboardHelper.dashboardSettingsShowGradeToggle.waitToExist()
        XCTAssertTrue(showGradeToggle.isVisible)
        XCTAssertEqual(showGradeToggle.value(), "0")

        // MARK: Tap Show Grade toggle and check value again
        showGradeToggle.tap()
        XCTAssertEqual(showGradeToggle.value(), "1")

        // MARK: Tap Done button then check visibility of course again
        var doneButton = DashboardHelper.doneButton.waitToExist()
        XCTAssertTrue(doneButton.isVisible)

        doneButton.tap()

        // MARK: Check grade on Course Card label
        courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        let courseCardLabel = courseCard.label()
        XCTAssertGreaterThan(courseCardLabel.count, 4)
        XCTAssertEqual(courseCardLabel.suffix(4), "100%")

        // MARK: Unselect Show Grades toggle then check Course Card label again
        dashboardSettingsButton = DashboardHelper.dashboardSettings.waitToExist()
        XCTAssertTrue(dashboardSettingsButton.isVisible)

        dashboardSettingsButton.tap()
        showGradeToggle = DashboardHelper.dashboardSettingsShowGradeToggle.waitToExist()
        XCTAssertTrue(showGradeToggle.isVisible)

        showGradeToggle.tap()
        doneButton = DashboardHelper.doneButton.waitToExist()
        XCTAssertTrue(doneButton.isVisible)

        doneButton.tap()
        courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
        XCTAssertTrue(courseCard.label().contains(course.name))
    }
}
