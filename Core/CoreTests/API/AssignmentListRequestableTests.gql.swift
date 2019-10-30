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
@testable import Core

class AssignmentListRequestableTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testDecode() {
        let str = """
        {
          "data": {
            "course": {
              "name": "Introduction to Jupiter",
              "gradingPeriods": {
                "nodes": [
                  {
                    "id": "3",
                    "title": "A",
                    "endDate": "2018-09-30T23:59:00-06:00",
                    "startDate": "2018-09-01T00:00:00-06:00"
                  },
                  {
                    "id": "4",
                    "title": "B",
                    "endDate": "2020-12-31T23:59:00-07:00",
                    "startDate": "2018-10-01T00:00:00-06:00"
                  }
                ]
              },
              "groups": {
                "nodes": [
                  {
                    "id": "6",
                    "name": "Assignments",
                    "assignmentNodes": {
                      "nodes": [
                        {
                          "id": "482",
                          "name": "jupiter is a great planet",
                          "inClosedGradingPeriod": false,
                          "dueAt": "2019-04-18T23:59:59-06:00",
                          "lockAt": null,
                          "unlockAt": "2019-04-17T09:43:00-06:00"
                          "quiz": {
                            "id": "1"
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          }
        }
        """
        let data = str.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var model: APIAssignmentListResponse?
        do {
            model = try decoder.decode(APIAssignmentListResponse.self, from: data!)
        } catch {
            print("error: \(error)")
        }

        XCTAssertNotNil(model)
        XCTAssertEqual(model?.gradingPeriods.count, 2)
        XCTAssertEqual(model?.groups.count, 1)
        XCTAssertEqual(model?.groups.first?.assignments.count, 1)

        let group = model?.groups.first
        XCTAssertEqual(group?.name, "Assignments")
        XCTAssertEqual(group?.id, "6")

        let a = model?.groups.first?.assignments.first

        XCTAssertEqual(a?.name, "jupiter is a great planet")
        XCTAssertEqual(a?.dueAt, Date(fromISOString: "2019-04-18T23:59:59-06:00"))
        XCTAssertEqual(a?.quizID, "1")

        let period = model?.gradingPeriods.first
        XCTAssertEqual(period?.title, "A")
    }

    func testFilterCurrentGradingPeriod() {
        let a = APIAssignmentListGradingPeriod(id: "1", title: "A", startDate: Date().addYears(-1), endDate: Date().addDays(-2))
        let b = APIAssignmentListGradingPeriod(id: "1", title: "A", startDate: Date().addDays(-1), endDate: Date().addDays(1))

        let periods: [APIAssignmentListGradingPeriod] = [a, b]
        XCTAssertEqual(periods.current, b)
    }
}
