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

@testable import Core
import XCTest

final class GetHSkillRequestTests: CoreTestCase {
    func testPath() {
        XCTAssertEqual(GetHSkillRequest().path, "/graphql")
    }

    func testHeader() {
        let request = GetHSkillRequest()
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers.first?.key, "Accept")
        XCTAssertEqual(request.headers.first?.value, "application/json")
    }

    func testShouldAddNoVerifierQuery() {
        let request = GetHSkillRequest()
        XCTAssertFalse(request.shouldAddNoVerifierQuery)
    }

    func testOperationName() {
        XCTAssertEqual(GetHSkillRequest.operationName, "Skills")
    }

    func testQuery() {
        let query = """
        query Skills {
            skills(completedOnly: true) {
                id,
                name,
                proficiencyLevel
            }
        }
        """
        XCTAssertEqual(GetHSkillRequest.query, query)
    }
}
