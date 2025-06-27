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

import XCTest
@testable import Teacher

class GradeStatusTests: XCTestCase {

    func test_init_userDefined() {
        let status = GradeStatus(userDefinedName: "Reviewed", id: "custom1")
        XCTAssertEqual(status, .userDefined(id: "custom1", name: "Reviewed"))
    }

    func test_init_defaultCase() {
        let status = GradeStatus(defaultStatus: "late")
        XCTAssertEqual(status, .late)
    }

    func test_properties_late() {
        let testee = GradeStatus.late
        XCTAssertEqual(testee.id, "late")
        XCTAssertEqual(testee.name, "Late")
        XCTAssertEqual(testee.isUserDefined, false)
    }

    func test_properties_missing() {
        let testee = GradeStatus.missing
        XCTAssertEqual(testee.id, "missing")
        XCTAssertEqual(testee.name, "Missing")
        XCTAssertEqual(testee.isUserDefined, false)
    }

    func test_properties_excused() {
        let testee = GradeStatus.excused
        XCTAssertEqual(testee.id, "excused")
        XCTAssertEqual(testee.name, "Excused")
        XCTAssertEqual(testee.isUserDefined, false)
    }

    func test_properties_extended() {
        let testee = GradeStatus.extended
        XCTAssertEqual(testee.id, "extended")
        XCTAssertEqual(testee.name, "Extended")
        XCTAssertEqual(testee.isUserDefined, false)
    }

    func test_properties_none() {
        let testee = GradeStatus.none
        XCTAssertEqual(testee.id, "none")
        XCTAssertEqual(testee.name, "None")
        XCTAssertEqual(testee.isUserDefined, false)
    }

    func test_properties_unknownDefault() {
        let testee = GradeStatus.unknownDefault("pending")
        XCTAssertEqual(testee.id, "pending")
        XCTAssertEqual(testee.name, "Pending")
        XCTAssertEqual(testee.isUserDefined, false)
    }

    func test_properties_userDefined() {
        let testee = GradeStatus.userDefined(id: "custom2", name: "Checked")
        XCTAssertEqual(testee.id, "custom2")
        XCTAssertEqual(testee.name, "Checked")
        XCTAssertEqual(testee.isUserDefined, true)
    }
}
