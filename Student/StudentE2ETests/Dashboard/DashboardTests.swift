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
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard2.isVisible)

        // MARK: Select a favorite course and check for dashboard updating
        let dashboardEditButton = Helper.editButton.waitUntil(.visible)
        XCTAssertTrue(dashboardEditButton.isVisible)

        dashboardEditButton.hit()
        Helper.toggleFavorite(course: courses[1])
        let navBarBackButton = Helper.backButton.waitUntil(.visible)
        XCTAssertTrue(navBarBackButton.isVisible)

        navBarBackButton.hit()
        pullToRefresh()
        XCTAssertTrue(courseCard2.waitUntil(.visible).isVisible)
        XCTAssertTrue(courseCard1.waitUntil(.vanish).isVanished)
    }

    func testAnnouncementBelowInvite() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()

        // MARK: Check for empty dashboard
        logInDSUser(student)
        let noCoursesLabel = Helper.noCoursesLabel.waitUntil(.visible)
        XCTAssertTrue(noCoursesLabel.isVisible)

        // MARK: Create an enrollment and an announcement
        let enrollment = seeder.enrollStudent(student, in: course, state: .invited)
        let announcement = AnnouncementsHelper.postAccountNotification()
        pullToRefresh(x: 1)

        // MARK: Check visibility and order of the enrollment and the announcement
        let courseAcceptButton = CourseInvitations.acceptButton(enrollment: enrollment).waitUntil(.visible)
        XCTAssertTrue(courseAcceptButton.isVisible)

        let notificationToggleButton = AccountNotifications.toggleButton(notification: announcement)
            .waitUntil(.visible)
        XCTAssertTrue(notificationToggleButton.isVisible)
        XCTAssertLessThan(courseAcceptButton.frame.maxY, notificationToggleButton.frame.minY)

        // MARK: Dismiss the notification
        notificationToggleButton.hit()
        let dismissButton = AccountNotifications.dismissButton(notification: announcement).waitUntil(.visible)
        XCTAssertTrue(dismissButton.isVisible)

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
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to pages of course and open front page
        courseCard.hit()
        CourseDetailsHelper.cell(type: .pages).hit()
        PagesHelper.frontPage.hit()
        XCTAssertTrue(courseCard.isVanished)

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
        XCTAssertTrue(courseCard.hasLabel(label: course.name, strict: false))
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
        XCTAssertTrue(courseCard1.hasLabel(label: courses[0].name, strict: false))

        var courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseCard2.hasLabel(label: courses[1].name, strict: false))

        // MARK: Tap edit button
        Helper.editButton.hit()

        // MARK: Completed, Active, Invited courses should be listed
        courseCard1 = Helper.courseCard(course: courses[0]).waitUntil(.visible)
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard1.hasLabel(label: courses[0].name, strict: false))

        courseCard2 = Helper.courseCard(course: courses[1]).waitUntil(.visible)
        XCTAssertTrue(courseCard2.isVisible)
        XCTAssertTrue(courseCard2.hasLabel(label: courses[1].name, strict: false))

        let courseCard3 = Helper.courseCard(course: courses[2]).waitUntil(.visible)
        XCTAssertTrue(courseCard3.isVisible)
        XCTAssertTrue(courseCard3.hasLabel(label: courses[2].name, strict: false))

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
        let courseCard = Helper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Check visibility of Dashboard Options button
        let dashboardOptionsButton = Helper.optionsButton.waitUntil(.visible)
        XCTAssertTrue(dashboardOptionsButton.isVisible)

        // MARK: Check visibility of Dashboard Settings button
        dashboardOptionsButton.hit()
        let dashboardSettingsButton = Helper.dashboardSettingsButton.waitUntil(.visible)
        XCTAssertTrue(dashboardSettingsButton.isVisible)

        // MARK: Tap Edit Dashboard button then check visibility and value of Show Grade toggle
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
        dashboardOptionsButton.waitUntil(.visible)
        XCTAssertTrue(dashboardOptionsButton.isVisible)

        dashboardOptionsButton.hit()
        dashboardSettingsButton.waitUntil(.visible)
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
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard2.isVisible)

        // MARK: Reorder course cards, check if successful
        let courseCard1FrameBefore = courseCard1.frame
        let courseCard2FrameBefore = courseCard2.frame
        courseCard1.tapAndHoldAndDragToElement(element: courseCard2)
        let courseCard1FrameAfter = courseCard1.frame
        let courseCard2FrameAfter = courseCard2.frame
        XCTAssertEqual(courseCard1FrameAfter, courseCard2FrameBefore)
        XCTAssertEqual(courseCard2FrameAfter, courseCard1FrameBefore)

        // MARK: Logout then login again to test if the changes are stored properly
        logOut()
        logInDSUser(student)
        courseCard1.waitUntil(.visible)
        courseCard2.waitUntil(.visible)
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard2.isVisible)
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
        XCTAssertTrue(courseCard.isVisible)
        XCTAssertTrue(courseOptionsButton.isVisible)

        // MARK: Navigate to Customize Course screen, check options
        courseOptionsButton.hit()
        let customizeCourseButton = Helper.CourseOptions.customizeCourseButton.waitUntil(.visible)
        XCTAssertTrue(customizeCourseButton.isVisible)

        customizeCourseButton.hit()
        let nicknameTextField = Helper.CourseOptions.CustomizeCourse.nicknameTextField.waitUntil(.visible)
        let doneButton = Helper.CourseOptions.CustomizeCourse.doneButton.waitUntil(.visible)
        XCTAssertTrue(nicknameTextField.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        for courseColor in Helper.CourseOptions.CustomizeCourse.CourseColor.allCases {
            let colorButton = Helper.CourseOptions.CustomizeCourse.colorButton(color: courseColor).waitUntil(.visible)
            XCTAssertTrue(colorButton.isVisible, "\(courseColor.rawValue) course color is not visible")
        }

        // MARK: Set nickname and color for course
        nicknameTextField.waitUntil(.hittable)
        nicknameTextField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        nicknameTextField.cutText(tapSelectAll: false)
        nicknameTextField.writeText(text: courseNickname)

        let randomColorButton = Helper.CourseOptions.CustomizeCourse.colorButton(color: .allCases.randomElement()!).waitUntil(.visible)
        XCTAssertTrue(randomColorButton.isVisible)

        randomColorButton.hit()
        doneButton.hit()
        XCTAssertTrue(courseCard.waitUntil(.visible).hasLabel(label: courseNickname, strict: false))
    }
}
