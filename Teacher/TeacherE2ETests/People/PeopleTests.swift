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

class PeopleTests: E2ETestCase {
    func testPeopleListAndContextCard() {
        // MARK: Seed the usual stuff with some additional people
        let users = seeder.createUsers(5)
        let course = seeder.createCourse()
        let students = [users[0], users[1], users[2]]
        let teachers = [users[3], users[4]]
        seeder.enrollStudents(students, in: course)
        seeder.enrollTeachers(teachers, in: course)

        // MARK: Get the user logged in
        logInDSUser(teachers[0])
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to People, Check visibility and order of the previously created people
        PeopleHelper.navigateToPeople(course: course)
        let person1 = PeopleHelper.peopleCell(index: 0).waitUntil(.visible)
        let person1RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 0).waitUntil(.visible)
        let person1NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 0).waitUntil(.visible)
        XCTAssertTrue(person1.isVisible)
        XCTAssertTrue(person1RoleLabel.isVisible)
        XCTAssertEqual(person1RoleLabel.label, "Student")
        XCTAssertTrue(person1NameLabel.isVisible)
        XCTAssertEqual(person1NameLabel.label, students[0].name)

        let person2 = PeopleHelper.peopleCell(index: 1).waitUntil(.visible)
        let person2RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 1).waitUntil(.visible)
        let person2NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 1).waitUntil(.visible)
        XCTAssertTrue(person2.isVisible)
        XCTAssertTrue(person2RoleLabel.isVisible)
        XCTAssertEqual(person2RoleLabel.label, "Student")
        XCTAssertTrue(person2NameLabel.isVisible)
        XCTAssertEqual(person2NameLabel.label, students[1].name)

        let person3 = PeopleHelper.peopleCell(index: 2).waitUntil(.visible)
        let person3RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 2).waitUntil(.visible)
        let person3NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 2).waitUntil(.visible)
        XCTAssertTrue(person3.isVisible)
        XCTAssertTrue(person3RoleLabel.isVisible)
        XCTAssertEqual(person3RoleLabel.label, "Student")
        XCTAssertTrue(person3NameLabel.isVisible)
        XCTAssertEqual(person3NameLabel.label, students[2].name)

        let person4 = PeopleHelper.peopleCell(index: 3).waitUntil(.visible)
        let person4RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 3).waitUntil(.visible)
        let person4NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 3).waitUntil(.visible)
        XCTAssertTrue(person4.isVisible)
        XCTAssertTrue(person4RoleLabel.isVisible)
        XCTAssertEqual(person4RoleLabel.label, "Teacher")
        XCTAssertTrue(person4NameLabel.isVisible)
        XCTAssertEqual(person4NameLabel.label, teachers[0].name)

        let person5 = PeopleHelper.peopleCell(index: 4).waitUntil(.visible)
        let person5RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 4).waitUntil(.visible)
        let person5NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 4).waitUntil(.visible)
        XCTAssertTrue(person5.isVisible)
        XCTAssertTrue(person5RoleLabel.isVisible)
        XCTAssertEqual(person5RoleLabel.label, "Teacher")
        XCTAssertTrue(person5NameLabel.isVisible)
        XCTAssertEqual(person5NameLabel.label, teachers[1].name)

        // MARK: Tap on one of them and check details on the Context Card
        let randomIndex = Int.random(in: 0...4)
        PeopleHelper.peopleCell(index: randomIndex).hit()

        let nameLabel = PeopleHelper.ContextCard.userNameLabel.waitUntil(.visible)
        let courseLabel = PeopleHelper.ContextCard.courseLabel.waitUntil(.visible)
        let sectionLabel = PeopleHelper.ContextCard.sectionLabel.waitUntil(.visible)
        XCTAssertTrue(nameLabel.isVisible)
        XCTAssertEqual(nameLabel.label, users[randomIndex].name)
        XCTAssertTrue(courseLabel.isVisible)
        XCTAssertEqual(courseLabel.label, course.name)
        XCTAssertTrue(sectionLabel.isVisible)
        XCTAssertEqual(sectionLabel.label, "Section: \(course.name)")
    }

    func testPeopleListUpdatesAfterEnrollmentOfPersonIsDeleted() {
        // MARK: Seed the usual stuff with some additional people
        let users = seeder.createUsers(2)
        let course = seeder.createCourse()
        let teachers = [users[0], users[1]]
        let enrollments = seeder.enrollTeachers(teachers, in: course)

        // MARK: Get the user logged in
        logInDSUser(teachers[0])
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to People, Check visibility and order of the previously created people
        PeopleHelper.navigateToPeople(course: course)
        let person1 = PeopleHelper.peopleCell(index: 0).waitUntil(.visible)
        let person1RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 0).waitUntil(.visible)
        let person1NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 0).waitUntil(.visible)
        XCTAssertTrue(person1.isVisible)
        XCTAssertTrue(person1RoleLabel.isVisible)
        XCTAssertEqual(person1RoleLabel.label, "Teacher")
        XCTAssertTrue(person1NameLabel.isVisible)
        XCTAssertEqual(person1NameLabel.label, teachers[0].name)

        let person2 = PeopleHelper.peopleCell(index: 1).waitUntil(.visible)
        let person2RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 1).waitUntil(.visible)
        let person2NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 1).waitUntil(.visible)
        XCTAssertTrue(person2.isVisible)
        XCTAssertTrue(person2RoleLabel.isVisible)
        XCTAssertEqual(person2RoleLabel.label, "Teacher")
        XCTAssertTrue(person2NameLabel.isVisible)
        XCTAssertEqual(person2NameLabel.label, teachers[1].name)

        // MARK: Delete enrollment of the other teacher and check if People List gets updated
        seeder.deleteEnrollment(enrollments[1], in: course)
        app.pullToRefresh(x: 0.1)
        person2.waitUntil(.vanish)
        XCTAssertTrue(person2.isVanished)
    }
}
