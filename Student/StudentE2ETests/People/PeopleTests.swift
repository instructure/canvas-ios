//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class PeopleTests: E2ETestCase {
    let studentLabel = "Student"
    let teacherLabel = "Teacher"
    let observerLabel = "Observer"

    func testPeopleListAndContextCard() {
        // MARK: Seed the usual stuff with some additional people
        let users = seeder.createUsers(5)
        let course = seeder.createCourse()
        let students = [users[0], users[1], users[2]]
        let teachers = [users[3], users[4]]
        seeder.enrollStudents(students, in: course)
        seeder.enrollTeachers(teachers, in: course)

        // MARK: Get the user logged in
        logInDSUser(students[0])
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to People
        PeopleHelper.navigateToPeople(course: course)

        // MARK: Check visibility and order of the previously created people
        let person1 = PeopleHelper.peopleCell(index: 0).waitUntil(.visible)
        let person1RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 0).waitUntil(.visible)
        let person1NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 0).waitUntil(.visible)
        XCTAssertVisible(person1)
        XCTAssertVisible(person1RoleLabel)
        XCTAssertEqual(person1RoleLabel.label, studentLabel)
        XCTAssertVisible(person1NameLabel)
        XCTAssertEqual(person1NameLabel.label, students[0].name)

        let person2 = PeopleHelper.peopleCell(index: 1).waitUntil(.visible)
        let person2RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 1).waitUntil(.visible)
        let person2NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 1).waitUntil(.visible)
        XCTAssertVisible(person2)
        XCTAssertVisible(person2RoleLabel)
        XCTAssertEqual(person2RoleLabel.label, studentLabel)
        XCTAssertVisible(person2NameLabel)
        XCTAssertEqual(person2NameLabel.label, students[1].name)

        let person3 = PeopleHelper.peopleCell(index: 2).waitUntil(.visible)
        let person3RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 2).waitUntil(.visible)
        let person3NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 2).waitUntil(.visible)
        XCTAssertVisible(person3)
        XCTAssertVisible(person3RoleLabel)
        XCTAssertEqual(person3RoleLabel.label, studentLabel)
        XCTAssertVisible(person3NameLabel)
        XCTAssertEqual(person3NameLabel.label, students[2].name)

        let person4 = PeopleHelper.peopleCell(index: 3).waitUntil(.visible)
        let person4RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 3).waitUntil(.visible)
        let person4NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 3).waitUntil(.visible)
        XCTAssertVisible(person4)
        XCTAssertVisible(person4RoleLabel)
        XCTAssertEqual(person4RoleLabel.label, teacherLabel)
        XCTAssertVisible(person4NameLabel)
        XCTAssertEqual(person4NameLabel.label, teachers[0].name)

        let person5 = PeopleHelper.peopleCell(index: 4).waitUntil(.visible)
        let person5RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 4).waitUntil(.visible)
        let person5NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 4).waitUntil(.visible)
        XCTAssertVisible(person5)
        XCTAssertVisible(person5RoleLabel)
        XCTAssertEqual(person5RoleLabel.label, teacherLabel)
        XCTAssertVisible(person5NameLabel)
        XCTAssertEqual(person5NameLabel.label, teachers[1].name)

        // MARK: Tap on one of them and check details on the Context Card
        let randomIndex = Int.random(in: 0...4)
        PeopleHelper.peopleCell(index: randomIndex).hit()

        let nameLabel = PeopleHelper.ContextCard.userNameLabel.waitUntil(.visible)
        XCTAssertVisible(nameLabel)
        XCTAssertEqual(nameLabel.label, users[randomIndex].name)

        let courseLabel = PeopleHelper.ContextCard.courseLabel.waitUntil(.visible)
        XCTAssertVisible(courseLabel)
        XCTAssertEqual(courseLabel.label, course.name)

        let sectionLabel = PeopleHelper.ContextCard.sectionLabel.waitUntil(.visible)
        XCTAssertVisible(sectionLabel)
        XCTAssertEqual(sectionLabel.label, "Section: \(course.name)")
    }

    func testPeopleListUpdatesAfterEnrollmentOfPersonIsDeleted() {
        // MARK: Seed the usual stuff with some additional people
        let users = seeder.createUsers(2)
        let course = seeder.createCourse()
        let students = [users[0], users[1]]
        let enrollments = seeder.enrollStudents(students, in: course)

        // MARK: Get the user logged in
        logInDSUser(students[0])
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to People
        PeopleHelper.navigateToPeople(course: course)

        // MARK: Check visibility and order of the previously created people
        let person1 = PeopleHelper.peopleCell(index: 0).waitUntil(.visible)
        let person1RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 0).waitUntil(.visible)
        let person1NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 0).waitUntil(.visible)
        XCTAssertVisible(person1)
        XCTAssertVisible(person1RoleLabel)
        XCTAssertEqual(person1RoleLabel.label, studentLabel)
        XCTAssertVisible(person1NameLabel)
        XCTAssertEqual(person1NameLabel.label, students[0].name)

        let person2 = PeopleHelper.peopleCell(index: 1).waitUntil(.visible)
        let person2RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 1).waitUntil(.visible)
        let person2NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 1).waitUntil(.visible)
        XCTAssertVisible(person2)
        XCTAssertVisible(person2RoleLabel)
        XCTAssertEqual(person2RoleLabel.label, studentLabel)
        XCTAssertVisible(person2NameLabel)
        XCTAssertEqual(person2NameLabel.label, students[1].name)

        // MARK: Delete enrollment of the other student and check if People List gets updated
        seeder.deleteEnrollment(enrollments[1], in: course)
        app.pullToRefresh(x: 0.1)
        person2.waitUntil(.vanish)
        XCTAssertTrue(person2.isVanished)
    }

    func testRoleFilters() {
        // MARK: Seed the usual stuff with some additional people
        let course = seeder.createCourse()
        let students = seeder.createUsers(2)
        let teachers = seeder.createUsers(2)
        let parents = seeder.createUsers(2)
        seeder.enrollStudents(students, in: course)
        seeder.enrollTeachers(teachers, in: course)
        seeder.enrollParent(parents[0], in: course, student: students[0])
        seeder.enrollParent(parents[1], in: course, student: students[1])

        // MARK: Get the user logged in
        logInDSUser(students[0])
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to People, 4 people should be displayed
        PeopleHelper.navigateToPeople(course: course)
        let person6 = PeopleHelper.peopleCell(index: 3).waitUntil(.visible)
        XCTAssertVisible(person6)

        // MARK: Check filters
        let filterButton = PeopleHelper.filterButton.waitUntil(.visible)
        XCTAssertVisible(filterButton)

        filterButton.hit()
        let observersButton = PeopleHelper.FilterOptions.observersButton.waitUntil(.visible)
        let studentsButton = PeopleHelper.FilterOptions.studentsButton.waitUntil(.visible)
        let teachersButton = PeopleHelper.FilterOptions.teachersButton.waitUntil(.visible)
        XCTAssertVisible(observersButton)
        XCTAssertVisible(studentsButton)
        XCTAssertVisible(teachersButton)

        // MARK: Filter for students, 2 people should be visible
        studentsButton.hit()
        let person3 = PeopleHelper.peopleCell(index: 2).waitUntil(.vanish)
        let person1RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 0).waitUntil(.visible)
        let person2RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 1).waitUntil(.visible)
        XCTAssertTrue(person3.isVanished)
        XCTAssertVisible(person1RoleLabel)
        XCTAssertVisible(person2RoleLabel)
        XCTAssertEqual(person1RoleLabel.waitUntil(.label(expected: studentLabel)).label, studentLabel)
        XCTAssertEqual(person2RoleLabel.waitUntil(.label(expected: studentLabel)).label, studentLabel)

        // MARK: Filter for teachers, 2 people should be visible
        let clearFilterButton = PeopleHelper.clearFilterButton.waitUntil(.visible)
        XCTAssertVisible(clearFilterButton)

        clearFilterButton.hit()
        filterButton.hit()
        teachersButton.hit()
        XCTAssertTrue(person3.waitUntil(.vanish).isVanished)
        XCTAssertVisible(person1RoleLabel.waitUntil(.visible))
        XCTAssertVisible(person2RoleLabel.waitUntil(.visible))
        XCTAssertEqual(person1RoleLabel.waitUntil(.label(expected: teacherLabel)).label, teacherLabel)
        XCTAssertEqual(person2RoleLabel.waitUntil(.label(expected: teacherLabel)).label, teacherLabel)

        // MARK: Filter for observers, 0 people should be visible
        clearFilterButton.hit()
        filterButton.hit()
        observersButton.hit()
        let person1 = PeopleHelper.peopleCell(index: 0).waitUntil(.vanish)
        XCTAssertTrue(person1.isVanished)
    }

    func testNewMessageFromPeopleDetailScreen() {
        // MARK: Seed the usual stuff with some additional people
        let course = seeder.createCourse()
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let messageSubject = "Please dont fail me"
        let messageBody = "I will do infinite assignments"
        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to People, open detail screen, Filter for teacher
        PeopleHelper.navigateToPeople(course: course)
        let filterButton = PeopleHelper.filterButton.waitUntil(.visible)
        XCTAssertVisible(filterButton)

        filterButton.hit()
        let teacherButton = PeopleHelper.FilterOptions.teachersButton.waitUntil(.visible)
        XCTAssertVisible(teacherButton)

        teacherButton.hit()
        let person1 = PeopleHelper.peopleCell(index: 0).waitUntil(.visible)
        XCTAssertVisible(person1)

        person1.hit()
        let sendEmailButton = PeopleHelper.ContextCard.sendEmailButton.waitUntil(.visible)
        XCTAssertVisible(sendEmailButton)

        // MARK: Tap the "Send Email" icon, Check recipient, Check elements
        sendEmailButton.hit()
        let sendButton = InboxHelper.Composer.sendButton.waitUntil(.visible)
        let courseSelector = InboxHelper.Composer.selectCourseButton.waitUntil(.visible)
        let subjectInput = InboxHelper.Composer.subjectInput.waitUntil(.visible)
        let messageInput = InboxHelper.Composer.bodyInput.waitUntil(.visible)
        let recipientPill = InboxHelper.Composer.recipientPillById(recipient: teacher)
        XCTAssertVisible(sendButton)
        XCTAssertVisible(courseSelector)
        XCTAssertVisible(subjectInput)
        XCTAssertVisible(messageInput)
        XCTAssertVisible(recipientPill)

        // MARK: Add a subject and a message, Tap send, Check result
        subjectInput.writeText(text: messageSubject)
        messageInput.writeText(text: messageBody)
        XCTAssertTrue(sendButton.waitUntil(.enabled).isEnabled)

        sendButton.hit()
        let inboxTab = DashboardHelper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertVisible(inboxTab)

        inboxTab.hit()
        let filterByTypeButton = InboxHelper.filterByTypeButton.waitUntil(.visible)
        XCTAssertVisible(filterByTypeButton)

        filterByTypeButton.hit()
        let sentOption = InboxHelper.Filter.sent.waitUntil(.visible)
        XCTAssertVisible(sentOption)

        sentOption.hit()
        let conversationButton = InboxHelper.conversations[0].waitUntil(.visible)
        XCTAssertVisible(conversationButton)
        XCTAssertContains(conversationButton.label, messageSubject)
    }
}
