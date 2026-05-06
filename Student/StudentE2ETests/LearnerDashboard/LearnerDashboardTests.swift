//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class LearnerDashboardTests: E2ETestCase {
    typealias Helper = LearnerDashboardHelper

    func testCoursesWidgetShowsCourses() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Login and check courses widget shows the course
        logInDSUser(student)
        let coursesHeader = Helper.CoursesWidget.coursesHeader.waitUntil(.visible)
        XCTAssertVisible(coursesHeader)

        let courseCard = Helper.CoursesWidget.courseCard(courseID: course.id).waitUntil(.visible)
        XCTAssertVisible(courseCard)
        XCTAssertContains(courseCard.label, course.name)
    }

    func testCustomizeDashboardButtonOpensSettings() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Login and check for Customize Dashboard button
        logInDSUser(student)
        let bottomSettingsButton = Helper.bottomSettingsButton.waitUntil(.visible)
        XCTAssertVisible(bottomSettingsButton)

        // MARK: Tap button and verify settings screen
        bottomSettingsButton.hit()
        let doneButton = Helper.Settings.doneButton.waitUntil(.visible)
        XCTAssertVisible(doneButton)

        let newDashboardToggle = Helper.Settings.newDashboardToggle.waitUntil(.visible)
        XCTAssertVisible(newDashboardToggle)
        XCTAssertEqual(newDashboardToggle.stringValue, "on")

        // MARK: Dismiss settings
        doneButton.hit()
        XCTAssertTrue(doneButton.waitUntil(.vanish).isVanished)
    }

    func testAllCoursesButtonNavigation() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Login and tap All Courses button
        logInDSUser(student)
        let allCoursesButton = Helper.CoursesWidget.allCoursesButton.waitUntil(.visible)
        XCTAssertVisible(allCoursesButton)

        // MARK: Verify All Courses screen shows the enrolled course
        allCoursesButton.hit()
        let courseItem = DashboardHelper.AllCourses.courseItem(course: course).waitUntil(.visible)
        XCTAssertVisible(courseItem)
        XCTAssertContains(courseItem.label, course.name)
    }

    func testToggleCoursesWidgetOffHidesWidget() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Login and verify courses widget is visible
        logInDSUser(student)
        var coursesHeader = Helper.CoursesWidget.coursesHeader.waitUntil(.visible)
        XCTAssertVisible(coursesHeader)

        // MARK: Open settings and toggle Courses & Groups widget off
        Helper.bottomSettingsButton.hit()
        let coursesWidgetToggle = Helper.Settings.widgetToggle(id: .coursesAndGroups).waitUntil(.visible)
        XCTAssertVisible(coursesWidgetToggle)
        XCTAssertEqual(coursesWidgetToggle.stringValue, "on")

        coursesWidgetToggle.hit()
        XCTAssertEqual(coursesWidgetToggle.stringValue, "off")

        Helper.Settings.doneButton.hit()

        // MARK: Verify courses header is no longer visible on dashboard
        coursesHeader = Helper.CoursesWidget.coursesHeader.waitUntil(.vanish)
        XCTAssertTrue(coursesHeader.isVanished)
    }

    func testCourseCardGradeVisibility() {
        // MARK: Seed the usual stuff with a graded assignment
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let pointsPossible: Float = 10
        let totalGrade = "100%"
        seeder.enrollStudent(student, in: course)

        let assignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: Float(pointsPossible), gradingType: .percent)
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)
        GradesHelper.gradeAssignment(grade: String(pointsPossible), course: course, assignment: assignment, user: student)

        // MARK: Login and verify grade pill is not shown by default
        logInDSUser(student)
        Helper.CoursesWidget.courseCard(courseID: course.id).waitUntil(.visible)

        var gradePill = Helper.CoursesWidget.courseCardGradePill.waitUntil(.vanish)
        XCTAssertTrue(gradePill.isVanished)

        // MARK: Open settings and enable Show Grades
        Helper.bottomSettingsButton.hit()
        let showGradesToggle = Helper.Settings.showGradesToggle.waitUntil(.visible)
        XCTAssertVisible(showGradesToggle)
        XCTAssertEqual(showGradesToggle.stringValue, "off")

        showGradesToggle.hit()
        XCTAssertEqual(showGradesToggle.stringValue, "on")

        Helper.Settings.doneButton.hit()

        // MARK: Verify grade pill appears with correct grade value
        gradePill = Helper.CoursesWidget.courseCardGradePill.waitUntil(.visible)
        XCTAssertVisible(gradePill)
        gradePill.actionUntilElementCondition(action: .pullToRefresh, condition: .labelHasPrefix(expected: totalGrade))
        XCTAssertTrue(gradePill.label.hasPrefix(totalGrade))
    }

    func testGlobalAnnouncementShownAndDismissed() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Login and post a global announcement
        logInDSUser(student)
        let announcement = AnnouncementsHelper.postAccountNotification()
        app.pullToRefresh()

        // MARK: Verify the announcement card is visible in the widget
        let announcementCard = Helper.AnnouncementsWidget.announcementCard(announcement: announcement).waitUntil(.visible)
        XCTAssertVisible(announcementCard)

        // MARK: Tap the card button and verify details screen opens
        let cardButton = Helper.AnnouncementsWidget.cardButton.waitUntil(.visible)
        XCTAssertVisible(cardButton)

        cardButton.hit()

        let dismissButton = Helper.AnnouncementsWidget.detailsDismissButton.waitUntil(.visible)
        XCTAssertVisible(dismissButton)

        // MARK: Dismiss the details screen
        dismissButton.hit()
        XCTAssertTrue(dismissButton.waitUntil(.vanish).isVanished)
    }
}
