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

class DashboardTests: E2ETestCase {
    typealias Helper = DashboardHelper
    typealias CourseInvitations = Helper.CourseInvitations
    typealias AccountNotifications = Helper.AccountNotifications

    func testDashboard() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course1 = seeder.createCourse()

        // MARK: Check for empty dashboard
        logInDSUser(teacher)
        let noCoursesLabel = app.find(label: "No Courses").waitUntil(.visible)
        XCTAssertTrue(noCoursesLabel.isVisible)

        // MARK: Check for course1
        seeder.enrollTeacher(teacher, in: course1)
        pullToRefresh(x: 1)
        let courseCard1 = Helper.courseCard(course: course1).waitUntil(.visible)
        XCTAssertTrue(courseCard1.isVisible)

        // MARK: Check for course2
        let course2 = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course2)
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
        let teacher = seeder.createUser()
        let course = seeder.createCourse()

        // MARK: Check for empty dashboard
        logInDSUser(teacher)
        XCTAssertTrue(app.find(label: "No Courses").waitUntil(.visible).isVisible)

        // MARK: Create an enrollment and an announcement
        let enrollment = seeder.enrollTeacher(teacher, in: course, state: .invited)
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
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        Helper.createFrontPageForCourse(course: course)

        // MARK: Get the user logged in and navigate to the course
        logInDSUser(teacher)
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
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in and check visibility and label of course
        logInDSUser(teacher)
        let courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)
        XCTAssertTrue(courseCard.label.contains(course.name))
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
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard1.label.contains(courses[0].name))

        var courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseCard2.label.contains(courses[1].name))

        // MARK: Tap edit button
        Helper.editButton.hit()

        // MARK: Completed, Active, Invited, Pending courses should be listed
        courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard1.label.contains(courses[0].name))

        courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseCard2.label.contains(courses[1].name))

        let courseCard3 = Helper.courseCard(course: courses[2]).waitUntil(.visible)
        XCTAssertTrue(courseCard3.isVisible)
        XCTAssertTrue(courseCard3.label.contains(courses[2].name))

        let courseCard4 = Helper.courseCard(course: courses[3]).waitUntil(.visible)
        XCTAssertTrue(courseCard4.isVisible)
        XCTAssertTrue(courseCard4.label.contains(courses[3].name))

        // MARK: Creation Deleted, Inactive, Rejected should not be listed
        let courseCard5 = Helper.courseCard(course: courses[4]).waitUntil(.vanish)
        XCTAssertTrue(courseCard5.isVanished)
        let courseCard6 = Helper.courseCard(course: courses[5]).waitUntil(.vanish)
        XCTAssertTrue(courseCard6.isVanished)
        let courseCard7 = Helper.courseCard(course: courses[6]).waitUntil(.vanish)
        XCTAssertTrue(courseCard7.isVanished)
    }
}
