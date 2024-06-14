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

class OfflineContentSyncTests: OfflineE2ETest {
    typealias Dashboard = DashboardHelper
    typealias Offline = Dashboard.Options.OfflineContent

    func testDiscussionsSync() {
        typealias Discussion = DiscussionsHelper
        typealias DiscussionDetails = Discussion.Details

        // MARK: Seed the usual stuff with a course containing a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let discussion = Discussion.createDiscussion(course: course)
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, open "Dashboard Options", open "Manage Offline Content"
        logInDSUser(student)
        let dashboardOptionsButton = Dashboard.optionsButton.waitUntil(.visible)
        let offlineCourseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        let onlineCourseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(dashboardOptionsButton.isVisible)
        XCTAssertTrue(offlineCourseCard.isVisible)
        XCTAssertTrue(onlineCourseCard.isVisible)

        dashboardOptionsButton.hit()
        let manageOfflineContentButton = Dashboard.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertTrue(manageOfflineContentButton.isVisible)

        manageOfflineContentButton.hit()

        // MARK: Select discussions to sync
        let arrowButton = Offline.arrowButtonOfCourse(course: course).waitUntil(.visible)
        let unselectedTickerOfCourseButton = Offline.unselectedTickerOfCourseButton(course: course).waitUntil(.visible)
        let partiallySelectedTickerOfCourseButton = Offline.partiallySelectedTickerOfCourseButton(course: course).waitUntil(.vanish)
        let syncButton = Offline.syncButton.waitUntil(.visible)
        XCTAssertTrue(arrowButton.isVisible)
        XCTAssertTrue(unselectedTickerOfCourseButton.isVisible)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.isVanished)
        XCTAssertTrue(syncButton.isVisible)

        arrowButton.hit()
        let discussionsButton = Offline.discussionsButton.waitUntil(.visible)
        discussionsButton.hit()

        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.waitUntil(.visible).isVisible)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = Offline.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = Offline.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = Offline.alertCancelButton.waitUntil(.visible)
        XCTAssertTrue(alertSyncOfflineContentLabel.isVisible)
        XCTAssertTrue(alertCancelButton.isVisible)
        XCTAssertTrue(alertSyncButton.isVisible)

        alertSyncButton.hit()
        let syncingOfflineContentLabel = Offline.syncingOfflineContentLabel.waitUntil(.visible)
        XCTAssertTrue(syncingOfflineContentLabel.isVisible)

        syncingOfflineContentLabel.waitUntil(.vanish)
        XCTAssertTrue(syncingOfflineContentLabel.isVanished)

        // MARK: Go offline, check the discussion
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = Dashboard.offlineLine.waitUntil(.visible)
        XCTAssertTrue(offlineLineImage.isVisible)

        offlineCourseCard.hit()
        discussionsButton.waitUntil(.visible, timeout: 90)
        XCTAssertTrue(discussionsButton.isVisible)

        discussionsButton.hit()
        let discussionItem = Discussion.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionItem.isVisible)

        // MARK: Open the discussion, check details
        discussionItem.hit()
        let detailsNavBar = DiscussionDetails.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let detailsOptionsButton = DiscussionDetails.optionsButton.waitUntil(.visible)
        XCTAssertTrue(detailsOptionsButton.isVisible)

        let detailsTitleLabel = DiscussionDetails.titleLabel.waitUntil(.visible)
        XCTAssertTrue(detailsTitleLabel.isVisible)
        XCTAssertEqual(detailsTitleLabel.label, discussion.title)

        let detailsLastPostLabel = DiscussionDetails.lastPostLabel.waitUntil(.visible)
        XCTAssertTrue(detailsLastPostLabel.isVisible)

        let detailsMessageLabel = DiscussionDetails.messageLabel.waitUntil(.visible)
        XCTAssertTrue(detailsMessageLabel.isVisible)
        XCTAssertEqual(detailsMessageLabel.label, discussion.message)

        let detailsReplyButton = DiscussionDetails.replyButton.waitUntil(.visible)
        XCTAssertTrue(detailsReplyButton.isVisible)
    }

    func testPagesSync() {
        typealias Page = PagesHelper

        // MARK: Seed the usual stuff with a course containing a page
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let page = Page.createPage(course: course)
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, open "Dashboard Options", open "Manage Offline Content"
        logInDSUser(student)
        let dashboardOptionsButton = Dashboard.optionsButton.waitUntil(.visible)
        let offlineCourseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        let onlineCourseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(dashboardOptionsButton.isVisible)
        XCTAssertTrue(offlineCourseCard.isVisible)
        XCTAssertTrue(onlineCourseCard.isVisible)

        dashboardOptionsButton.hit()
        let manageOfflineContentButton = Dashboard.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertTrue(manageOfflineContentButton.isVisible)

        manageOfflineContentButton.hit()

        // MARK: Select pages to sync
        let arrowButton = Offline.arrowButtonOfCourse(course: course).waitUntil(.visible)
        let unselectedTickerOfCourseButton = Offline.unselectedTickerOfCourseButton(course: course).waitUntil(.visible)
        let partiallySelectedTickerOfCourseButton = Offline.partiallySelectedTickerOfCourseButton(course: course).waitUntil(.vanish)
        let syncButton = Offline.syncButton.waitUntil(.visible)
        XCTAssertTrue(arrowButton.isVisible)
        XCTAssertTrue(unselectedTickerOfCourseButton.isVisible)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.isVanished)
        XCTAssertTrue(syncButton.isVisible)

        arrowButton.hit()
        let pagesButton = Offline.pagesButton.waitUntil(.visible)
        pagesButton.hit()

        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.waitUntil(.visible).isVisible)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = Offline.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = Offline.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = Offline.alertCancelButton.waitUntil(.visible)
        XCTAssertTrue(alertSyncOfflineContentLabel.isVisible)
        XCTAssertTrue(alertCancelButton.isVisible)
        XCTAssertTrue(alertSyncButton.isVisible)

        alertSyncButton.hit()
        let syncingOfflineContentLabel = Offline.syncingOfflineContentLabel.waitUntil(.visible)
        XCTAssertTrue(syncingOfflineContentLabel.isVisible)

        syncingOfflineContentLabel.waitUntil(.vanish)
        XCTAssertTrue(syncingOfflineContentLabel.isVanished)

        // MARK: Go offline, check the discussion
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = Dashboard.offlineLine.waitUntil(.visible)
        XCTAssertTrue(offlineLineImage.isVisible)

        offlineCourseCard.hit()
        pagesButton.waitUntil(.visible, timeout: 90)
        XCTAssertTrue(pagesButton.isVisible)

        pagesButton.hit()
        let pageItem = Page.page(index: 0).waitUntil(.visible)
        XCTAssertTrue(pageItem.isVisible)

        // MARK: Open the page, check title and body
        pageItem.hit()
        XCTAssertTrue(app.find(labelContaining: page.title).waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: page.body).waitUntil(.visible).isVisible)
    }

    func testGradesSync() {
        typealias Assignment = AssignmentsHelper
        typealias Grade = GradesHelper

        // MARK: Seed the usual stuff with a course containing an assignment
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let assignment = Assignment.createAssignment(course: course, gradingType: .letter_grade)
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let dashboardOptionsButton = Dashboard.optionsButton.waitUntil(.visible)
        let courseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(dashboardOptionsButton.isVisible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Create a submission for the assignment, get it graded
        Grade.submitAssignment(course: course, student: student, assignment: assignment)
        Grade.gradeAssignment(grade: "A", course: course, assignment: assignment, user: student)

        // MARK: Open "Dashboard Options" then "Manage Offline Content"
        dashboardOptionsButton.hit()
        let manageOfflineContentButton = Dashboard.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertTrue(manageOfflineContentButton.isVisible)

        manageOfflineContentButton.hit()

        // MARK: Select grades to sync
        let arrowButton = Offline.arrowButtonOfCourse(course: course).waitUntil(.visible)
        let unselectedTickerOfCourseButton = Offline.unselectedTickerOfCourseButton(course: course).waitUntil(.visible)
        let partiallySelectedTickerOfCourseButton = Offline.partiallySelectedTickerOfCourseButton(course: course).waitUntil(.vanish)
        let syncButton = Offline.syncButton.waitUntil(.visible)
        XCTAssertTrue(arrowButton.isVisible)
        XCTAssertTrue(unselectedTickerOfCourseButton.isVisible)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.isVanished)
        XCTAssertTrue(syncButton.isVisible)

        arrowButton.hit()
        let gradesButton = Offline.gradesButton.waitUntil(.visible)
        gradesButton.hit()

        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.waitUntil(.visible).isVisible)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = Offline.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = Offline.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = Offline.alertCancelButton.waitUntil(.visible)
        XCTAssertTrue(alertSyncOfflineContentLabel.isVisible)
        XCTAssertTrue(alertCancelButton.isVisible)
        XCTAssertTrue(alertSyncButton.isVisible)

        alertSyncButton.hit()
        let syncingOfflineContentLabel = Offline.syncingOfflineContentLabel.waitUntil(.visible)
        XCTAssertTrue(syncingOfflineContentLabel.isVisible)

        syncingOfflineContentLabel.waitUntil(.vanish)
        XCTAssertTrue(syncingOfflineContentLabel.isVanished)

        // MARK: Go offline, check the grade
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = Dashboard.offlineLine.waitUntil(.visible)
        XCTAssertTrue(offlineLineImage.isVisible)

        courseCard.hit()
        gradesButton.waitUntil(.visible, timeout: 90)
        XCTAssertTrue(gradesButton.isVisible)

        // MARK: Check grade and total grade
        gradesButton.hit()
        let totalGrade = Grade.totalGrade.waitUntil(.visible)
        let gradeAssignmentCell = Grade.gradesAssignmentButton(assignment: assignment).waitUntil(.visible)
        let gradeItem = Grade.gradeLabel(assignmentCell: gradeAssignmentCell).waitUntil(.visible)
        XCTAssertTrue(totalGrade.isVisible)
        XCTAssertTrue(totalGrade.waitUntil(.label(expected: "Total grade is 100%")).hasLabel(label: "Total grade is 100%"))
        XCTAssertTrue(gradeItem.isVisible)
        XCTAssertTrue(gradeItem.waitUntil(.label(expected: "Grade, 1 out of 1 (A)")).hasLabel(label: "Grade, 1 out of 1 (A)"))
    }

    func testPeopleSync() {
        typealias People = PeopleHelper
        typealias ContextCard = People.ContextCard

        // MARK: Seed the usual stuff with a course containing some people
        let course = seeder.createCourse()
        let student = BaseHelper.createUser(type: .student, enrollIn: course)
        let students = BaseHelper.createUsers(2, type: .student, enrollIn: course)
        let teachers = BaseHelper.createUsers(2, type: .teacher, enrollIn: course)

        // MARK: Get the user logged in, open "Dashboard Options", open "Manage Offline Content"
        logInDSUser(student)
        let dashboardOptionsButton = Dashboard.optionsButton.waitUntil(.visible)
        let offlineCourseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        let onlineCourseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(dashboardOptionsButton.isVisible)
        XCTAssertTrue(offlineCourseCard.isVisible)
        XCTAssertTrue(onlineCourseCard.isVisible)

        dashboardOptionsButton.hit()
        let manageOfflineContentButton = Dashboard.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertTrue(manageOfflineContentButton.isVisible)

        manageOfflineContentButton.hit()

        // MARK: Select people to sync
        let arrowButton = Offline.arrowButtonOfCourse(course: course).waitUntil(.visible)
        let unselectedTickerOfCourseButton = Offline.unselectedTickerOfCourseButton(course: course).waitUntil(.visible)
        let partiallySelectedTickerOfCourseButton = Offline.partiallySelectedTickerOfCourseButton(course: course).waitUntil(.vanish)
        let syncButton = Offline.syncButton.waitUntil(.visible)
        XCTAssertTrue(arrowButton.isVisible)
        XCTAssertTrue(unselectedTickerOfCourseButton.isVisible)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.isVanished)
        XCTAssertTrue(syncButton.isVisible)

        arrowButton.hit()
        let peopleButton = Offline.peopleButton.waitUntil(.visible)
        peopleButton.hit()

        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.waitUntil(.visible).isVisible)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = Offline.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = Offline.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = Offline.alertCancelButton.waitUntil(.visible)
        XCTAssertTrue(alertSyncOfflineContentLabel.isVisible)
        XCTAssertTrue(alertCancelButton.isVisible)
        XCTAssertTrue(alertSyncButton.isVisible)

        alertSyncButton.hit()
        let syncingOfflineContentLabel = Offline.syncingOfflineContentLabel.waitUntil(.visible)
        XCTAssertTrue(syncingOfflineContentLabel.isVisible)

        syncingOfflineContentLabel.waitUntil(.vanish)
        XCTAssertTrue(syncingOfflineContentLabel.isVanished)

        // MARK: Go offline, check the grade
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = Dashboard.offlineLine.waitUntil(.visible)
        XCTAssertTrue(offlineLineImage.isVisible)

        offlineCourseCard.hit()
        peopleButton.waitUntil(.visible, timeout: 90)
        XCTAssertTrue(peopleButton.isVisible)

        // MARK: Check people list
        peopleButton.hit()
        for p in 0 ..< students.count + teachers.count {
            let person = PeopleHelper.peopleCell(index: p).waitUntil(.visible)
            XCTAssertTrue(person.isVisible)

            let personNameLabel = PeopleHelper.nameLabelOfPeopleCell(index: p).waitUntil(.visible)
            XCTAssertTrue(personNameLabel.isVisible)

            let expectedRoleLabel = teachers.filter { $0.name == personNameLabel.label }.count > 0 ? "Teacher" : "Student"

            let personRoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: p).waitUntil(.visible)
            XCTAssertTrue(personRoleLabel.isVisible)
            XCTAssertTrue(personRoleLabel.hasLabel(label: expectedRoleLabel))
        }
    }

    func testSyllabusSync() {
        typealias Syllabus = SyllabusHelper
        // MARK: Seed the usual stuff with a course containing a syllabus
        let student = seeder.createUser()
        let course = Syllabus.createCourseWithSyllabus()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, open "Dashboard Options", open "Manage Offline Content"
        logInDSUser(student)
        let dashboardOptionsButton = Dashboard.optionsButton.waitUntil(.visible)
        let offlineCourseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        let onlineCourseCard = Dashboard.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(dashboardOptionsButton.isVisible)
        XCTAssertTrue(offlineCourseCard.isVisible)
        XCTAssertTrue(onlineCourseCard.isVisible)

        dashboardOptionsButton.hit()
        let manageOfflineContentButton = Dashboard.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertTrue(manageOfflineContentButton.isVisible)

        manageOfflineContentButton.hit()

        // MARK: Select grades to sync
        let arrowButton = Offline.arrowButtonOfCourse(course: course).waitUntil(.visible)
        let unselectedTickerOfCourseButton = Offline.unselectedTickerOfCourseButton(course: course).waitUntil(.visible)
        let partiallySelectedTickerOfCourseButton = Offline.partiallySelectedTickerOfCourseButton(course: course).waitUntil(.vanish)
        let syncButton = Offline.syncButton.waitUntil(.visible)
        XCTAssertTrue(arrowButton.isVisible)
        XCTAssertTrue(unselectedTickerOfCourseButton.isVisible)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.isVanished)
        XCTAssertTrue(syncButton.isVisible)

        arrowButton.hit()
        let syllabusButton = Offline.syllabusButton.waitUntil(.visible)
        syllabusButton.hit()

        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.waitUntil(.visible).isVisible)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = Offline.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = Offline.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = Offline.alertCancelButton.waitUntil(.visible)
        XCTAssertTrue(alertSyncOfflineContentLabel.isVisible)
        XCTAssertTrue(alertCancelButton.isVisible)
        XCTAssertTrue(alertSyncButton.isVisible)

        alertSyncButton.hit()
        let syncingOfflineContentLabel = Offline.syncingOfflineContentLabel.waitUntil(.visible)
        XCTAssertTrue(syncingOfflineContentLabel.isVisible)

        syncingOfflineContentLabel.waitUntil(.vanish)
        XCTAssertTrue(syncingOfflineContentLabel.isVanished)

        // MARK: Go offline, check the syllabus
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = Dashboard.offlineLine.waitUntil(.visible)
        XCTAssertTrue(offlineLineImage.isVisible)

        offlineCourseCard.hit()
        syllabusButton.waitUntil(.visible, timeout: 90)
        XCTAssertTrue(syllabusButton.isVisible)

        // MARK: Check the syllabus
        syllabusButton.hit()
        let navBar = SyllabusHelper.navBar(course: course).waitUntil(.visible)
        let syllabusBodyLabel = SyllabusHelper.syllabusBody.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(syllabusBodyLabel.isVisible)
        XCTAssertTrue(syllabusBodyLabel.hasLabel(label: course.syllabus_body!))
    }
}
