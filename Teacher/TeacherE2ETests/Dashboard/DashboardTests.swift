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

class DashboardTests: E2ETestCase {
    typealias Helper = DashboardHelper
    typealias CourseInvitations = Helper.CourseInvitations
    typealias AccountNotifications = Helper.AccountNotifications

    func testDashboardFavoriteCourse() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let courses = seeder.createCourses(count: 2)
        seeder.enrollTeacher(teacher, in: courses[0])
        seeder.enrollTeacher(teacher, in: courses[1])

        // MARK: Check for course cards
        logInDSUser(teacher)
        let courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        let courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertVisible(courseCard1)
        XCTAssertVisible(courseCard2)

        // MARK: Select a favorite course and check for dashboard updating
        let dashboardEditButton = Helper.editButton.waitUntil(.visible)
        XCTAssertVisible(dashboardEditButton)

        dashboardEditButton.hit()
        Helper.toggleFavorite(course: courses[1])
        let navBarBackButton = Helper.backButton.waitUntil(.visible)
        XCTAssertVisible(navBarBackButton)

        navBarBackButton.hit()
        app.pullToRefresh()
        XCTAssertTrue(courseCard2.waitUntil(.visible).isVisible)
        XCTAssertTrue(courseCard1.waitUntil(.vanish).isVanished)
    }

    func testAnnouncementBelowInvite() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()

        // MARK: Check for empty dashboard
        logInDSUser(teacher)
        let noCoursesLabel = app.find(label: "No Courses").waitUntil(.visible)
        XCTAssertVisible(noCoursesLabel)

        // MARK: Create an enrollment and an announcement
        let enrollment = seeder.enrollTeacher(teacher, in: course, state: .invited)
        let announcement = AnnouncementsHelper.postAccountNotification()
        app.pullToRefresh()

        // MARK: Check visibility and order of the enrollment and the announcement
        let courseAcceptButton = CourseInvitations.acceptButton(enrollment: enrollment).waitUntil(.visible)
        XCTAssertVisible(courseAcceptButton)

        let notificationToggleButton = AccountNotifications.toggleButton(notification: announcement).waitUntil(.visible)
        XCTAssertVisible(notificationToggleButton)
        XCTAssertLessThan(courseAcceptButton.frame.maxY, notificationToggleButton.frame.minY)

        notificationToggleButton.hit()
        let dismissButton = AccountNotifications.dismissButton(notification: announcement).waitUntil(.visible)
        XCTAssertVisible(dismissButton)

        dismissButton.hit()
        XCTAssertTrue(dismissButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(notificationToggleButton.waitUntil(.vanish).isVanished)
    }

    func testNavigateToDashboard() {
        // MARK: Seed the usual stuff and a front page for the course
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        Helper.createFrontPageForCourse(course: course)

        // MARK: Get the user logged in and navigate to the course
        logInDSUser(teacher)
        var courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to pages of course and open front page
        courseCard.hit()
        let pagesButton = CourseDetailsHelper.cell(type: .pages).waitUntil(.visible)
        XCTAssertVisible(pagesButton)

        pagesButton.hit()
        let frontPageButton = PagesHelper.frontPage.waitUntil(.visible)
        XCTAssertVisible(frontPageButton)

        frontPageButton.hit()

        // MARK: Tap dashboard tab and check visibility of course card and label
        Helper.TabBar.dashboardTab.hit()
        let coursesLabel = Helper.coursesLabel.waitUntil(.visible)
        courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(coursesLabel)
        XCTAssertVisible(courseCard)
    }

    func testCourseCardInfo() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in and check visibility and label of course
        logInDSUser(teacher)
        let courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)
        XCTAssertContains(courseCard.label, course.name)
    }

    func testDashboardEditButtonDisplaysCorrectCourses() {
        // MARK: Seed the usual stuff with 7 courses and teacher enrolled in them with all 7 different states
        let teacher = seeder.createUser()
        let courses = Helper.createCourses(number: 7)
        seeder.enrollTeacher(teacher, in: courses[0], state: .active)
        seeder.enrollTeacher(teacher, in: courses[1], state: .invited)
        seeder.enrollTeacher(teacher, in: courses[2], state: .completed)
        seeder.enrollTeacher(teacher, in: courses[3], state: .creation_pending)
        seeder.enrollTeacher(teacher, in: courses[4], state: .deleted)
        seeder.enrollTeacher(teacher, in: courses[5], state: .inactive)
        seeder.enrollTeacher(teacher, in: courses[6], state: .rejected)

        // MARK: Get the user logged in and check visibility and label of courses
        logInDSUser(teacher)
        var courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        var courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertVisible(courseCard1)
        XCTAssertContains(courseCard1.label, courses[0].name)
        XCTAssertVisible(courseCard2)
        XCTAssertContains(courseCard2.label, courses[1].name)

        // MARK: Tap edit button
        Helper.editButton.hit()

        // MARK: Completed, Active, Invited, Pending courses should be listed
        courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        let courseCard3 = Helper.courseCard(course: courses[2]).waitUntil(.visible)
        let courseCard4 = Helper.courseCard(course: courses[3]).waitUntil(.visible)
        XCTAssertVisible(courseCard1)
        XCTAssertContains(courseCard1.label, courses[0].name)
        XCTAssertVisible(courseCard2)
        XCTAssertContains(courseCard2.label, courses[1].name)
        XCTAssertVisible(courseCard3)
        XCTAssertContains(courseCard3.label, courses[2].name)
        XCTAssertVisible(courseCard4)
        XCTAssertContains(courseCard4.label, courses[3].name)

        // MARK: Creation Deleted, Inactive, Rejected should not be listed
        let courseCard5 = Helper.courseCard(course: courses[4]).waitUntil(.vanish)
        let courseCard6 = Helper.courseCard(course: courses[5]).waitUntil(.vanish)
        let courseCard7 = Helper.courseCard(course: courses[6]).waitUntil(.vanish)
        XCTAssertTrue(courseCard5.isVanished)
        XCTAssertTrue(courseCard6.isVanished)
        XCTAssertTrue(courseCard7.isVanished)
    }
}
