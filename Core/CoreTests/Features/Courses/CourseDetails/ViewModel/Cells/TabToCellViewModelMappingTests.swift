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

@testable import Core
import XCTest

class TabToCellViewModelMappingTests: CoreTestCase {

    func testAttendanceCellCreation() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(id: "context_external_tool_123"), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        XCTAssertTrue(tab.toCellViewModel(attendanceToolID: "123", course: course, cellSelectionAction: {}) is AttendanceCellViewModel)
    }

    func testLTICellCreation() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(url: URL(string: "/lti")!, type: .external), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        XCTAssertTrue(tab.toCellViewModel(attendanceToolID: "123", course: course, cellSelectionAction: {}) is LTICellViewModel)
    }

    func testSyllabusCellCreation() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(id: "syllabus"), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        XCTAssertTrue(tab.toCellViewModel(attendanceToolID: "123", course: course, cellSelectionAction: {}) is SyllabusCellViewModel)
    }

    func testGenericCellCreation() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        XCTAssertTrue(tab.toCellViewModel(attendanceToolID: "123", course: course, cellSelectionAction: {}) is GenericCellViewModel)
    }
}
