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

import XCTest
import TestsFoundation

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
        logInDSUser(students[0])

        // MARK: Navigate to People
        PeopleHelper.navigateToPeople(course: course)

        // MARK: Check visibility and order of the previously created people
        let person1 = PeopleHelper.peopleCell(index: 0).waitToExist()
        XCTAssertTrue(person1.isVisible)
        let person1RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 0).waitToExist()
        XCTAssertTrue(person1RoleLabel.isVisible)
        XCTAssertEqual(person1RoleLabel.label(), "Student")
        let person1NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 0).waitToExist()
        XCTAssertTrue(person1NameLabel.isVisible)
        XCTAssertEqual(person1NameLabel.label(), students[0].name)

        let person2 = PeopleHelper.peopleCell(index: 1).waitToExist()
        XCTAssertTrue(person2.isVisible)
        let person2RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 1).waitToExist()
        XCTAssertTrue(person2RoleLabel.isVisible)
        XCTAssertEqual(person2RoleLabel.label(), "Student")
        let person2NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 1).waitToExist()
        XCTAssertTrue(person2NameLabel.isVisible)
        XCTAssertEqual(person2NameLabel.label(), students[1].name)

        let person3 = PeopleHelper.peopleCell(index: 2).waitToExist()
        XCTAssertTrue(person3.isVisible)
        let person3RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 2).waitToExist()
        XCTAssertTrue(person3RoleLabel.isVisible)
        XCTAssertEqual(person3RoleLabel.label(), "Student")
        let person3NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 2).waitToExist()
        XCTAssertTrue(person3NameLabel.isVisible)
        XCTAssertEqual(person3NameLabel.label(), students[2].name)

        let person4 = PeopleHelper.peopleCell(index: 3).waitToExist()
        XCTAssertTrue(person4.isVisible)
        let person4RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 3).waitToExist()
        XCTAssertTrue(person4RoleLabel.isVisible)
        XCTAssertEqual(person4RoleLabel.label(), "Teacher")
        let person4NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 3).waitToExist()
        XCTAssertTrue(person4NameLabel.isVisible)
        XCTAssertEqual(person4NameLabel.label(), teachers[0].name)

        let person5 = PeopleHelper.peopleCell(index: 4).waitToExist()
        XCTAssertTrue(person5.isVisible)
        let person5RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 4).waitToExist()
        XCTAssertTrue(person5RoleLabel.isVisible)
        XCTAssertEqual(person5RoleLabel.label(), "Teacher")
        let person5NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 4).waitToExist()
        XCTAssertTrue(person5NameLabel.isVisible)
        XCTAssertEqual(person5NameLabel.label(), teachers[1].name)

        // MARK: Tap on one of them and check details on the Context Card
        let randomIndex = Int.random(in: 0...5)
        PeopleHelper.peopleCell(index: randomIndex).tap()

        let nameLabel = PeopleHelper.ContextCard.userNameLabel.waitToExist()
        XCTAssertTrue(nameLabel.isVisible)
        XCTAssertEqual(nameLabel.label(), users[randomIndex].name)

        let courseLabel = PeopleHelper.ContextCard.courseLabel.waitToExist()
        XCTAssertTrue(courseLabel.isVisible)
        XCTAssertEqual(courseLabel.label(), course.name)

        let sectionLabel = PeopleHelper.ContextCard.sectionLabel.waitToExist()
        XCTAssertTrue(sectionLabel.isVisible)
        XCTAssertEqual(sectionLabel.label(), "Section: \(course.name)")
    }

    func testPeopleListUpdatesAfterEnrollmentOfPersonIsDeleted() {
        // MARK: Seed the usual stuff with some additional people
        let users = seeder.createUsers(2)
        let course = seeder.createCourse()
        let students = [users[0], users[1]]
        let enrollments = seeder.enrollStudents(students, in: course)

        // MARK: Get the user logged in
        logInDSUser(students[0])

        // MARK: Navigate to People
        PeopleHelper.navigateToPeople(course: course)

        // MARK: Check visibility and order of the previously created people
        let person1 = PeopleHelper.peopleCell(index: 0).waitToExist()
        XCTAssertTrue(person1.isVisible)
        let person1RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 0).waitToExist()
        XCTAssertTrue(person1RoleLabel.isVisible)
        XCTAssertEqual(person1RoleLabel.label(), "Student")
        let person1NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 0).waitToExist()
        XCTAssertTrue(person1NameLabel.isVisible)
        XCTAssertEqual(person1NameLabel.label(), students[0].name)

        var person2 = PeopleHelper.peopleCell(index: 1).waitToExist()
        XCTAssertTrue(person2.isVisible)
        let person2RoleLabel = PeopleHelper.roleLabelOfPeopleCell(index: 1).waitToExist()
        XCTAssertTrue(person2RoleLabel.isVisible)
        XCTAssertEqual(person2RoleLabel.label(), "Student")
        let person2NameLabel = PeopleHelper.nameLabelOfPeopleCell(index: 1).waitToExist()
        XCTAssertTrue(person2NameLabel.isVisible)
        XCTAssertEqual(person2NameLabel.label(), students[1].name)

        // MARK: Delete enrollment of the other student and check if People List gets updated
        seeder.deleteEnrollment(enrollments[1], in: course)
        PeopleHelper.pullToRefresh()
        person2 = PeopleHelper.peopleCell(index: 1).waitToVanish()
        XCTAssertFalse(person2.isVisible)
    }
}
