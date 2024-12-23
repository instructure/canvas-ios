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

import Foundation
import XCTest
@testable import Core

class SearchRecipientTests: CoreTestCase {
    func testSaveIntoCoreData() {
        SearchRecipient.make(from: APISearchRecipient.make(
            id: "1",
            name: "Jane",
            full_name: "Jane Doe",
            avatar_url: URL(string: "https://fillmurray.com/200/200"),
            type: .course,
            common_courses: [
                "1": ["Teacher"],
                "2": ["Student"]
            ])
        )

        let model: SearchRecipient = databaseClient.fetch().first!

        XCTAssertEqual(model.id, "1")
        XCTAssertEqual(model.fullName, "Jane Doe")
        XCTAssertEqual(model.avatarURL?.absoluteString, "https://fillmurray.com/200/200")
        XCTAssertEqual(model.filter, "per_page=50&context=course_1&search=&synthetic_contexts=1&type=user")
        XCTAssertEqual(model.commonCourses.count, 2)
        XCTAssertEqual(model.commonCourses.first { $0.courseID == "1" }?.role, "Teacher")
        XCTAssertEqual(model.commonCourses.first { $0.courseID == "2" }?.role, "Student")
    }

    func testUpdateExisting() {
        SearchRecipient.make()

        let item = APISearchRecipient.make(full_name: "Jane Doe")
        SearchRecipient.save(item, filter: "per_page=50&context=course_1&search=&synthetic_contexts=1&type=user", in: databaseClient)

        let model: SearchRecipient = databaseClient.fetch().first!
        XCTAssertEqual(model.fullName, "Jane Doe")
    }

    func testHasRole() {
        let model = SearchRecipient.make(from: .make(common_courses: [
            "1": ["TeacherEnrollment"],
            "2": ["StudentEnrollment"]
        ]))
        XCTAssertTrue(model.hasRole(.teacher, in: Context(.course, id: "1")))
        XCTAssertTrue(model.hasRole(.student, in: Context(.course, id: "2")))
        XCTAssertFalse(model.hasRole(.student, in: Context(.course, id: "1")))
        XCTAssertFalse(model.hasRole(.teacher, in: Context(.course, id: "2")))
        XCTAssertFalse(model.hasRole(.teacher, in: Context(.group, id: "1")))
        XCTAssertFalse(model.hasRole(.student, in: Context(.course, id: "3")))
    }
}
