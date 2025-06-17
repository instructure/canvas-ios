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

    func test_init_with_custom_grade_status() {
        let custom = APIGradeStatuses.CustomGradeStatus(color: "#FF0000", name: "Reviewed", id: "custom1")
        let status = GradeStatus(custom: custom)
        XCTAssertEqual(status.id, "custom1")
        XCTAssertEqual(status.name, "Reviewed")
        XCTAssertTrue(status.isCustom)
    }

    func test_init_with_default_name() {
        let status = GradeStatus(defaultName: "late")
        XCTAssertEqual(status.id, "late")
        XCTAssertEqual(status.name, String(localized: "Late", bundle: .teacher))
        XCTAssertFalse(status.isCustom)
    }

    func test_localized_grade_status_name() {
        XCTAssertEqual("late".localizedGradeStatusName, String(localized: "Late", bundle: .teacher))
        XCTAssertEqual("missing".localizedGradeStatusName, String(localized: "Missing", bundle: .teacher))
        XCTAssertEqual("excused".localizedGradeStatusName, String(localized: "Excused", bundle: .teacher))
        XCTAssertEqual("extended".localizedGradeStatusName, String(localized: "Extended", bundle: .teacher))
        XCTAssertEqual("none".localizedGradeStatusName, String(localized: "None", bundle: .teacher))
        XCTAssertEqual("other".localizedGradeStatusName, "Other")
    }
}
