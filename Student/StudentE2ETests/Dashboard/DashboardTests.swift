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
import XCTest

class DashboardTests: E2ETestCase {
    typealias Helper = DashboardHelper
    typealias CourseInvitations = Helper.CourseInvitations
    typealias AccountNotifications = Helper.AccountNotifications

    func testDashboardFavoriteCourse() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let courses = seeder.createCourses(count: 2)
        seeder.enrollStudent(student, in: courses[0])
        seeder.enrollStudent(student, in: courses[1])

        // MARK: Check for course cards
        logInDSUser(student)
        let courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        let courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertVisible(courseCard1)
        XCTAssertVisible(courseCard2)

        // MARK: Select a favorite course and check for dashboard updating
        let allCoursesButton = Helper.allCoursesButton.waitUntil(.visible)
        XCTAssertVisible(allCoursesButton)

        allCoursesButton.hit()
        Helper.AllCourses.toggleFavorite(course: courses[1])
        let navBarBackButton = Helper.backButtonByLabel.waitUntil(.visible)
        XCTAssertVisible(navBarBackButton)

        navBarBackButton.hit()
        app.pullToRefresh()
        XCTAssertVisible(courseCard2.waitUntil(.visible))
        XCTAssertTrue(courseCard1.waitUntil(.vanish).isVanished)
    }

    func testAnnouncementBelowInvite() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()

        // MARK: Check for empty dashboard
        logInDSUser(student)
        let noCoursesLabel = Helper.noCoursesLabel.waitUntil(.visible)
        XCTAssertVisible(noCoursesLabel)

        // MARK: Create an enrollment and an announcement
        let enrollment = seeder.enrollStudent(student, in: course, state: .invited)
        let announcement = AnnouncementsHelper.postAccountNotification()
        app.pullToRefresh(x: 1)

        // MARK: Check visibility and order of the enrollment and the announcement
        let courseAcceptButton = CourseInvitations.acceptButton(enrollment: enrollment).waitUntil(.visible)
        XCTAssertVisible(courseAcceptButton)

        let notificationToggleButton = AccountNotifications.toggleButton(notification: announcement)
            .waitUntil(.visible)
        XCTAssertVisible(notificationToggleButton)
        XCTAssertLessThan(courseAcceptButton.frame.maxY, notificationToggleButton.frame.minY)

        // MARK: Dismiss the notification
        notificationToggleButton.hit()
        let dismissButton = AccountNotifications.dismissButton(notification: announcement).waitUntil(.visible)
        XCTAssertVisible(dismissButton)

        dismissButton.hit()
        XCTAssertTrue(dismissButton.waitUntil(.vanish).isVanished)
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
        XCTAssertVisible(courseCard)

        // MARK: Navigate to pages of course and open front page
        courseCard.hit()
        CourseDetailsHelper.cell(type: .pages).hit()
        PagesHelper.frontPage.hit()
        XCTAssertTrue(courseCard.isVanished)

        // MARK: Tap dashboard tab and check visibility of course card and label
        Helper.TabBar.dashboardTab.hit()
        let coursesLabel = Helper.coursesLabel.waitUntil(.visible)
        courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(coursesLabel)
        XCTAssertVisible(courseCard)
    }

    func testCourseCardInfo() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in and check visibility and label of course
        logInDSUser(student)
        let courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)
        XCTAssertContains(courseCard.label, course.name)
    }

    func testAllCoursesDisplaysCorrectCourses() {
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
        XCTAssertVisible(courseCard1)
        XCTAssertContains(courseCard1.label, courses[0].name)

        var courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertVisible(courseCard2)
        XCTAssertContains(courseCard2.label, courses[1].name)

        // MARK: Tap All Courses button
        Helper.allCoursesButton.hit()

        // MARK: Completed, Active, Invited courses should be listed
        courseCard1 = Helper.AllCourses.courseItem(course: courses[0]).waitUntil(.visible)
        XCTAssertVisible(courseCard1)
        XCTAssertContains(courseCard1.label, courses[0].name)

        courseCard2 = Helper.AllCourses.courseItem(course: courses[1]).waitUntil(.visible)
        XCTAssertVisible(courseCard2)
        XCTAssertContains(courseCard2.label, courses[1].name)

        let courseCard3 = Helper.AllCourses.courseItem(course: courses[2]).waitUntil(.visible)
        XCTAssertVisible(courseCard3)
        XCTAssertContains(courseCard3.label, courses[2].name)

        // MARK: Creation Pending, Deleted, Inactive, Rejected should not be listed
        let courseCard4 = Helper.AllCourses.courseItem(course: courses[3]).waitUntil(.vanish)
        XCTAssertTrue(courseCard4.isVanished)
        let courseCard5 = Helper.AllCourses.courseItem(course: courses[4]).waitUntil(.vanish)
        XCTAssertTrue(courseCard5.isVanished)
        let courseCard6 = Helper.AllCourses.courseItem(course: courses[5]).waitUntil(.vanish)
        XCTAssertTrue(courseCard6.isVanished)
        let courseCard7 = Helper.AllCourses.courseItem(course: courses[6]).waitUntil(.vanish)
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
        let courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Check visibility of Dashboard Options button
        let dashboardOptionsButton = Helper.optionsButton.waitUntil(.visible)
        XCTAssertVisible(dashboardOptionsButton)

        // MARK: Check visibility of Dashboard Settings button
        dashboardOptionsButton.hit()
        let dashboardSettingsButton = Helper.settingsButton.waitUntil(.visible)
        XCTAssertVisible(dashboardSettingsButton)

        // MARK: Tap Edit Dashboard button then check visibility and value of Show Grade toggle
        dashboardSettingsButton.hit()
        var showGradeToggle = Helper.dashboardSettingsShowGradeToggle.waitUntil(.visible)
        XCTAssertVisible(showGradeToggle)
        XCTAssertEqual(showGradeToggle.stringValue, "off")

        // MARK: Tap Show Grade toggle and check value again
        showGradeToggle.tap()
        XCTAssertEqual(showGradeToggle.stringValue, "on")

        // MARK: Tap Done button then check visibility of course again
        var doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertVisible(doneButton)

        doneButton.hit()

        // MARK: Check grade on Course Card label
        courseCard.waitUntil(.visible)
        XCTAssertVisible(courseCard)

        let courseCardGradeLabel = DashboardHelper.courseCardGradeLabel(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCardGradeLabel)
        courseCardGradeLabel.actionUntilElementCondition(action: .pullToRefresh, condition: .label(expected: totalGrade))
        XCTAssertEqual(courseCardGradeLabel.label, totalGrade)

        // MARK: Unselect Show Grades toggle then check Course Card label again
        dashboardOptionsButton.waitUntil(.visible)
        XCTAssertVisible(dashboardOptionsButton)

        dashboardOptionsButton.hit()
        dashboardSettingsButton.waitUntil(.visible)
        XCTAssertVisible(dashboardSettingsButton)

        dashboardSettingsButton.hit()
        showGradeToggle = Helper.dashboardSettingsShowGradeToggle.waitUntil(.visible)
        XCTAssertVisible(showGradeToggle)

        showGradeToggle.tap()
        doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertVisible(doneButton)

        doneButton.hit()
        courseCard.waitUntil(.visible)
        courseCardGradeLabel.waitUntil(.vanish)
        XCTAssertVisible(courseCard)
        XCTAssertTrue(courseCardGradeLabel.isVanished)
    }

    func testCourseCardReorder() {
        // MARK: Seed the usual stuff with 2 courses
        let student = seeder.createUser()
        let courses = seeder.createCourses(count: 2)
        seeder.enrollStudent(student, in: courses[0])
        seeder.enrollStudent(student, in: courses[1])

        // MARK: Get the user logged in, check course cards
        logInDSUser(student)
        let courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        let courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertVisible(courseCard1)
        XCTAssertVisible(courseCard2)

        // MARK: Reorder course cards, check if successful
        let courseCard1FrameBefore = courseCard1.frame
        let courseCard2FrameBefore = courseCard2.frame
        courseCard1.tapAndHoldAndDragToElement(element: courseCard2)
        courseCard1.tacticalSleep(2) // wait for animation to finish
        let courseCard1FrameAfter = courseCard1.frame
        let courseCard2FrameAfter = courseCard2.frame
        XCTAssertEqual(courseCard1FrameAfter, courseCard2FrameBefore)
        XCTAssertEqual(courseCard2FrameAfter, courseCard1FrameBefore)

        // MARK: Logout then login again to test if the changes are stored properly
        logOut()
        logInDSUser(student)
        courseCard1.waitUntil(.visible)
        courseCard2.waitUntil(.visible)
        XCTAssertVisible(courseCard1)
        XCTAssertVisible(courseCard2)
        XCTAssertEqual(courseCard1FrameAfter, courseCard2FrameBefore)
        XCTAssertEqual(courseCard2FrameAfter, courseCard1FrameBefore)
    }

    func testCourseNicknameAndColor() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let courseNickname = "Course Nickname"
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, check course card
        logInDSUser(student)
        let courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        let courseOptionsButton = Helper.courseOptionsButton(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)
        XCTAssertVisible(courseOptionsButton)

        // MARK: Navigate to Customize Course screen, check options
        courseOptionsButton.hit()
        let customizeCourseButton = Helper.CourseOptions.customizeCourseButton.waitUntil(.visible)
        XCTAssertVisible(customizeCourseButton)

        customizeCourseButton.hit()
        let nicknameTextField = Helper.CourseOptions.CustomizeCourse.nicknameTextField.waitUntil(.visible)
        let doneButton = Helper.CourseOptions.CustomizeCourse.doneButton.waitUntil(.visible)
        XCTAssertVisible(nicknameTextField)
        XCTAssertVisible(doneButton)

        for courseColor in Helper.CourseOptions.CustomizeCourse.CourseColor.allCases {
            let colorButton = Helper.CourseOptions.CustomizeCourse.colorButton(color: courseColor).waitUntil(.visible)
            XCTAssertVisible(colorButton)
        }

        // MARK: Set nickname and color for course
        nicknameTextField.waitUntil(.hittable)
        nicknameTextField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        nicknameTextField.cutText(tapSelectAll: false)
        nicknameTextField.writeText(text: courseNickname)

        let randomColorButton = Helper.CourseOptions.CustomizeCourse.colorButton(color: .allCases.randomElement()!).waitUntil(.visible)
        XCTAssertVisible(randomColorButton)

        randomColorButton.hit()
        doneButton.hit()
        XCTAssertContains(courseCard.waitUntil(.visible).label, courseNickname)
    }
}
