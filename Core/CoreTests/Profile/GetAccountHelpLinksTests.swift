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

@testable import Core
import XCTest
import TestsFoundation

class GetAccountHelpLinksTests: CoreTestCase {
    func testGetAccountHelpLinks() {
        XCTAssertEqual(GetAccountHelpLinks(for: .student).request.path, "accounts/self/help_links")
        GetAccountHelpLinks(for: .student).write(response: .make(), urlResponse: nil, to: databaseClient)

        let observer: [HelpLink] = databaseClient.fetch(GetAccountHelpLinks(for: .observer).scope.predicate)
        XCTAssertEqual(observer.count, 3)
        let teacher: [HelpLink] = databaseClient.fetch(GetAccountHelpLinks(for: .teacher).scope.predicate)
        XCTAssertEqual(teacher.count, 3)
        let student: [HelpLink] = databaseClient.fetch(GetAccountHelpLinks(for: .student).scope.predicate)
        XCTAssertEqual(student.count, 4)
    }

    func testWriteEmpty() {
        GetAccountHelpLinks(for: .student).write(response: nil, urlResponse: nil, to: databaseClient)
        let links: [HelpLink] = databaseClient.fetch(GetAccountHelpLinks(for: .student).scope.predicate)
        XCTAssertEqual(links.count, 0)
    }

    func testWriteCustom() {
        GetAccountHelpLinks(for: .student).write(response: .make(custom_help_links: [
            .instructorQuestion,
            .make(id: "1", text: "Parent", subtext: nil, available_to: [.observer], url: .make()),
            .make(id: "2", text: "Teacher", subtext: nil, available_to: [.teacher], url: .make()),
            .make(id: "3", text: "Student", subtext: nil, available_to: [.student], url: .make())
        ]), urlResponse: nil, to: databaseClient)

        let observer: [HelpLink] = databaseClient.fetch(scope: GetAccountHelpLinks(for: .observer).scope)
        XCTAssertEqual(observer.count, 2)
        XCTAssertEqual(observer[0].text, "Help")
        XCTAssertEqual(observer[1].text, "Parent")
        XCTAssertEqual(observer[1].availableTo, [.observer])
        let teacher: [HelpLink] = databaseClient.fetch(scope: GetAccountHelpLinks(for: .teacher).scope)
        XCTAssertEqual(teacher.count, 2)
        XCTAssertEqual(teacher[0].text, "Help")
        XCTAssertEqual(teacher[1].text, "Teacher")
        XCTAssertEqual(teacher[1].availableTo, [.teacher])
        let student: [HelpLink] = databaseClient.fetch(scope: GetAccountHelpLinks(for: .student).scope)
        XCTAssertEqual(student.count, 3)
        XCTAssertEqual(student[0].text, "Help")
        XCTAssertEqual(student[1].text, "Ask Your Instructor a Question")
        XCTAssertEqual(student[2].text, "Student")
        XCTAssertEqual(student[2].availableTo, [.student])
    }

    func testNilCustom() {
        GetAccountHelpLinks(for: .student).write(response: .make(custom_help_links: [
            .make(id: nil, text: nil, subtext: nil, available_to: [.student], url: nil)
        ]), urlResponse: nil, to: databaseClient)

        let student: [HelpLink] = databaseClient.fetch(scope: GetAccountHelpLinks(for: .student).scope)
        XCTAssertEqual(student.count, 2)
        XCTAssertNil(student[1].id)
        XCTAssertNil(student[1].text)
        XCTAssertNil(student[1].subtext)
        XCTAssertEqual(student[1].availableTo, [.student])
        XCTAssertNil(student[1].url)
    }

    func testAvailableTo() {
        GetAccountHelpLinks(for: .student).write(response: .make(custom_help_links: [
            .make(id: "1", text: "Parent", subtext: nil, available_to: [.observer, .unenrolled], url: .make()),
            .make(id: "2", text: "Teacher", subtext: nil, available_to: [.teacher, .unenrolled], url: .make()),
            .make(id: "3", text: "Student", subtext: nil, available_to: [.student, .unenrolled], url: .make())
        ]), urlResponse: nil, to: databaseClient)

        let observer: [HelpLink] = databaseClient.fetch(scope: GetAccountHelpLinks(for: .observer).scope)
        XCTAssertEqual(observer.count, 2)
        let teacher: [HelpLink] = databaseClient.fetch(scope: GetAccountHelpLinks(for: .teacher).scope)
        XCTAssertEqual(teacher.count, 2)
        let student: [HelpLink] = databaseClient.fetch(scope: GetAccountHelpLinks(for: .student).scope)
        XCTAssertEqual(student.count, 2)
    }
}
