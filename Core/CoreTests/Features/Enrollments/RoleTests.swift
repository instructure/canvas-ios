//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core
import XCTest

class RoleTests: CoreTestCase {
    func testRawValue() {
        XCTAssertEqual(Role(rawValue: "TaEnrollment")?.rawValue, "TaEnrollment")
        XCTAssertEqual(Role(rawValue: "TeacherEnrollment")?.rawValue, "TeacherEnrollment")
        XCTAssertEqual(Role(rawValue: "StudentEnrollment")?.rawValue, "StudentEnrollment")
        XCTAssertEqual(Role(rawValue: "ObserverEnrollment")?.rawValue, "ObserverEnrollment")
        XCTAssertEqual(Role(rawValue: "DesignerEnrollment")?.rawValue, "DesignerEnrollment")
        XCTAssertEqual(Role(rawValue: "Custom")?.rawValue, "Custom")
    }

    func testDescription() {
        XCTAssertEqual(Role(rawValue: "TaEnrollment")?.description(), "TA")
        XCTAssertEqual(Role(rawValue: "TeacherEnrollment")?.description(), "Teacher")
        XCTAssertEqual(Role(rawValue: "StudentEnrollment")?.description(), "Student")
        XCTAssertEqual(Role(rawValue: "ObserverEnrollment")?.description(), "Observer")
        XCTAssertEqual(Role(rawValue: "DesignerEnrollment")?.description(), "Designer")
        XCTAssertEqual(Role(rawValue: "Custom")?.description(), "Custom")
    }

    func testEquatable() {
        XCTAssertEqual(Role.custom("illustrator"), .custom("illustrator"))
        XCTAssertEqual(Role.designer, .designer)
        XCTAssertEqual(Role.observer, .observer)
        XCTAssertEqual(Role.student, .student)
        XCTAssertEqual(Role.ta, .ta)
        XCTAssertEqual(Role.teacher, .teacher)
        XCTAssertNotEqual(Role.student, .teacher)
        XCTAssertNotEqual(Role.teacher, .ta)
        XCTAssertNotEqual(Role.designer, .custom("designer"))
        XCTAssertNotEqual(Role.teacher, .custom("TeacherEnrollment"))
    }
}
