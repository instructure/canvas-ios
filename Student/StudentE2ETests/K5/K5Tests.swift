//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5Tests: K5E2ETestCase {
    typealias Helper = K5Helper
    typealias ScheduleHelper = Helper.Schedule

    func testK5Homeroom() {
        // MARK: Seed the usual stuff with homeroom and course
        let student = seeder.createK5User()
        let homeroom = seeder.createK5Course()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: homeroom)
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, check elements of Homeroom
        logInDSUser(student)
        let welcomeMessage = Helper.Homeroom.welcomeMessage(student: student).waitUntil(.visible)
        XCTAssertTrue(welcomeMessage.isVisible)

        let mySubjectsLabel = Helper.Homeroom.mySubjects.waitUntil(.visible)
        XCTAssertTrue(mySubjectsLabel.isVisible)

        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        let homeroomButton = Helper.homeroom.waitUntil(.visible)
        let scheduleButton = Helper.schedule.waitUntil(.visible)
        let gradesButton = Helper.grades.waitUntil(.visible)
        let resourcesButton = Helper.resources.waitUntil(.visible)
        let importantDatesButton = Helper.importantDates.waitUntil(.visible)
        XCTAssertTrue(homeroomButton.waitUntil(.hittable).isHittable)
        XCTAssertTrue(homeroomButton.isSelected)
        XCTAssertTrue(scheduleButton.waitUntil(.hittable).isHittable)

        scheduleButton.actionUntilElementCondition(action: .swipeLeft(.onElement), element: importantDatesButton, condition: .hittable)
        XCTAssertTrue(gradesButton.waitUntil(.hittable).isHittable)
        XCTAssertTrue(resourcesButton.waitUntil(.hittable).isHittable)
        XCTAssertTrue(importantDatesButton.waitUntil(.hittable).isHittable)
    }

    func testK5Schedule() {
        // MARK: Seed the usual stuff with homeroom, course, assignment, quiz
        let student = seeder.createK5User()
        let homeroom = seeder.createK5Course()
        let course = seeder.createCourse()
        let todaysAssignment = AssignmentsHelper.createAssignment(
            course: course, dueDate: Date.now.addMinutes(30))
        let tomorrowsQuiz = QuizzesHelper.createTestQuizWith2Questions(
            course: course, due_at: Date.now.addDays(1))
        seeder.enrollStudent(student, in: homeroom)
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Schedule, check elements
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        let scheduleButton = Helper.schedule.waitUntil(.visible)
        scheduleButton.hit()
        XCTAssertTrue(scheduleButton.waitUntil(.selected).isSelected)

        let assignmentItemButton = ScheduleHelper.assignmentItemButton(assignment: todaysAssignment).waitUntil(.hittable)
        XCTAssertTrue(assignmentItemButton.isHittable)

        let quizItemButton = ScheduleHelper.quizItemButton(quiz: tomorrowsQuiz).waitUntil(.hittable)
        XCTAssertTrue(quizItemButton.isHittable)
    }

    func testK5Grades() {
        // MARK: Seed the usual stuff with homeroom, course, graded assignment
        let student = seeder.createK5User()
        let homeroom = seeder.createK5Course()
        let course = seeder.createCourse()
        let assignment = AssignmentsHelper.createAssignment(course: course, gradingType: .letter_grade, dueDate: Date.now.addMinutes(30))
        seeder.enrollStudent(student, in: homeroom)
        seeder.enrollStudent(student, in: course)
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)
        GradesHelper.gradeAssignment(grade: "A", course: course, assignment: assignment, user: student)

        // MARK: Get the user logged in, navigate to Grades, check elements
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        let gradesButton = Helper.grades.waitUntil(.visible)
        Helper.schedule.actionUntilElementCondition(action: .swipeLeft(.onElement), element: gradesButton, condition: .hittable)
        gradesButton.hit()
        XCTAssertTrue(gradesButton.waitUntil(.selected).isSelected)

        let selectGradingPeriodButton = Helper.Grades.selectGradingPeriodButton.waitUntil(.visible)
        XCTAssertTrue(selectGradingPeriodButton.isVisible)
        XCTAssertTrue(selectGradingPeriodButton.label.hasSuffix("Closed"))

        selectGradingPeriodButton.hit()
        let currentGradingPeriodButton = Helper.Grades.currentGradingPeriodButton.waitUntil(.visible)
        XCTAssertTrue(currentGradingPeriodButton.isVisible)

        currentGradingPeriodButton.hit()

        let courseProgressCard = Helper.Grades.courseProgressCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseProgressCard.isVisible)
        XCTAssertTrue(courseProgressCard.label.hasSuffix("100%"))

        courseProgressCard.hit()

        let courseGradesButton = CourseDetailsHelper.cell(type: .grades).waitUntil(.visible)
        courseGradesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable)
        courseGradesButton.hit()

        let totalGrade = GradesHelper.totalGrade.waitUntil(.visible)
        XCTAssertTrue(totalGrade.isVisible)
        XCTAssertTrue(totalGrade.hasLabel(label: "100%"))

        let assignmentGrade = GradesHelper.cell(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentGrade.isVisible)

        let assignmentGradeOutOf = GradesHelper.gradeOutOf(
                assignment: assignment,
                actualPoints: String(assignment.points_possible!),
                maxPoints: String(assignment.points_possible!),
                letterGrade: "A").waitUntil(.visible)
        XCTAssertTrue(assignmentGradeOutOf.isVisible)
    }

    func testK5CourseDetails() {
        // MARK: Seed the usual stuff with homeroom and other contents
        let student = seeder.createK5User()
        let homeroom = seeder.createK5Course()
        let course = seeder.createCourse(syllabus_body: "K5 Syllabus")
        let module = ModulesHelper.createModule(course: course)
        seeder.enrollStudent(student, in: homeroom)
        seeder.enrollStudent(student, in: course)
        AssignmentsHelper.createAssignment(course: course)
        AnnouncementsHelper.createAnnouncements(course: course)
        DiscussionsHelper.createDiscussion(course: course)
        PagesHelper.createPage(course: course)
        ModulesHelper.createModulePage(course: course, module: module)

        // MARK: Get the user logged in, navigate to course details
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        courseCard.hit()

        // MARK: Check buttons of course details
        let homeButton = CourseDetailsHelper.cell(type: .home).waitUntil(.visible)
        XCTAssertTrue(homeButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let announcementsButton = CourseDetailsHelper.cell(type: .announcements).waitUntil(.visible)
        XCTAssertTrue(announcementsButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let assignmentsButton = CourseDetailsHelper.cell(type: .assignments).waitUntil(.visible)
        XCTAssertTrue(assignmentsButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let discussionsButton = CourseDetailsHelper.cell(type: .discussions).waitUntil(.visible)
        XCTAssertTrue(discussionsButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let gradesButton = CourseDetailsHelper.cell(type: .grades).waitUntil(.visible)
        XCTAssertTrue(gradesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let peopleButton = CourseDetailsHelper.cell(type: .people).waitUntil(.visible)
        XCTAssertTrue(peopleButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let pagesButton = CourseDetailsHelper.cell(type: .pages).waitUntil(.visible)
        XCTAssertTrue(pagesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus).waitUntil(.visible)
        XCTAssertTrue(syllabusButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let modulesButton = CourseDetailsHelper.cell(type: .modules).waitUntil(.visible)
        XCTAssertTrue(modulesButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let bigBlueButtonButton = CourseDetailsHelper.cell(type: .bigBlueButton).waitUntil(.visible)
        XCTAssertTrue(bigBlueButtonButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let collaborationsButton = CourseDetailsHelper.cell(type: .collaborations).waitUntil(.visible)
        XCTAssertTrue(collaborationsButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))

        let googleDriveButton = CourseDetailsHelper.cell(type: .googleDrive).waitUntil(.visible)
        XCTAssertTrue(googleDriveButton.actionUntilElementCondition(action: .swipeUp(), condition: .hittable))
    }
}
