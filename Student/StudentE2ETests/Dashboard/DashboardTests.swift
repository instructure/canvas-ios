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
        let users = seeder.createUsers(1)
        let course1 = seeder.createCourse()
        let student = users[0]

        // MARK: Check for empty dashboard
        logInDSUser(student)
        let noCoursesLabel = app.find(label: "No Courses").waitToExist()
        XCTAssertTrue(noCoursesLabel.isVisible)

        // MARK: Check for course1
        _ = seeder.enrollStudent(student, in: course1)
        pullToRefresh()
        let courseCard1 = Dashboard.courseCard(id: course1.id).waitToExist()
        XCTAssertTrue(courseCard1.isVisible)

        // MARK: Check for course2
        let course2 = seeder.createCourse()
        _ = seeder.enrollStudent(student, in: course2)
        pullToRefresh()
        let courseCard2 = Dashboard.courseCard(id: course2.id).waitToExist()
        XCTAssertTrue(courseCard1.isVisible)

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

    func testNavigateToDashboard() throws {
        try XCTSkipIf(true, "passes locally but fails on bitrise")
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.pages.tap()
        PageList.frontPage.tap()

        TabBar.dashboardTab.tap()
        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "263").waitToExist()
    }

    func testCourseCardInfo() {
        Dashboard.courseCard(id: "263").waitToExist()
        XCTAssertEqual(Dashboard.courseCard(id: "263").label(), "Assignments assignments")
    }

    func testSeeAllButtonDisplaysCorrectCourses() throws {
        try XCTSkipIf(true, "passes locally but fails on bitrise")
        Dashboard.editButton.tap()

        // expired course and others should be listed
        Dashboard.courseCard(id: "303").waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        Dashboard.courseCard(id: "262").waitToExist()
        Dashboard.courseCard(id: "263").waitToExist()

        // Invite Only should not be listed
        Dashboard.courseCard(id: "338").waitToVanish()
    }

    func testCourseCardGrades() {
        Dashboard.dashboardSettings().waitToExist(10).tap()
        Dashboard.dashboardSettingsShowGradeToggle().waitToExist(10)
        if !Dashboard.dashboardSettingsShowGradeToggle().isSelected {
            Dashboard.dashboardSettingsShowGradeToggle().tap()
        }
        app.find(label: "Done").tap()
        pullToRefresh()
        Dashboard.courseCard(id: "263").waitToExist(5)
        XCTAssertEqual(Dashboard.courseCard(id: "263").label(), "Assignments assignments 72.73%")

        Dashboard.dashboardSettings().waitToExist(5).tap()
        Dashboard.dashboardSettingsShowGradeToggle().waitToExist(5).tap()
        app.find(label: "Done").tap()
        Dashboard.courseCard(id: "263").waitToExist(5)

        XCTAssertEqual(Dashboard.courseCard(id: "263").label().trimmingCharacters(in: .whitespacesAndNewlines), "Assignments assignments")
    }
}
