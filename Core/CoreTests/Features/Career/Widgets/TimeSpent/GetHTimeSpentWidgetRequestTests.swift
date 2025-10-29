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

final class GetHTimeSpentWidgetRequestTests: CoreTestCase {
    func testPath() {
        XCTAssertEqual(GetHTimeSpentWidgetRequest().path, "/graphql")
    }

    func testHeader() {
        let request = GetHTimeSpentWidgetRequest()
        // Headers stored as [String: String?]; mirror GetHSkillRequestTests pattern
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers[HttpHeader.accept]!, "application/json")
    }

    func testShouldAddNoVerifierQuery() {
        let request = GetHTimeSpentWidgetRequest()
        XCTAssertFalse(request.shouldAddNoVerifierQuery)
    }

    func testOperationName() {
        XCTAssertEqual(GetHTimeSpentWidgetRequest.operationName, "TimeSpentWidget")
    }

    func testQuery() {
        let expected = """
    query TimeSpentWidget {
        widgetData(
          widgetType: "time_spent_details",
          dataScope: "learner",
          timeSpan: {
            type: PAST_7_DAYS
          }
        ) {
          data
          lastModifiedDate
        }
      }
    """
        XCTAssertEqual(GetHTimeSpentWidgetRequest.query, expected)
    }

    func testVariables() {
        let request = GetHTimeSpentWidgetRequest()
        XCTAssertEqual(request.variables, .init())
    }
}
