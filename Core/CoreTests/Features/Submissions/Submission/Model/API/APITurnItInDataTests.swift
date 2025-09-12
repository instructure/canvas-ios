//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class APITurnItInDataTests: CoreTestCase {

    func testDecodeAPITurnItInData() {
        let json: Any = [
            "eula_agreement_timestamp": "123456",
            "attachment_1": [
                "status": "scored",
                "similarity_score": 0,
                "outcome_response": [
                    "outcomes_tool_placement_url": "https://canvas.instructure.com/tool/1"
                ]
            ],
            "submission_1": [
                "status": "scored"
            ]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        let turnItInData = try! JSONDecoder().decode(APITurnItInData.self, from: data)
        XCTAssertEqual(turnItInData.rawValue.keys.count, 2)
        XCTAssertEqual(turnItInData.rawValue["attachment_1"]?.status, "scored")
        XCTAssertEqual(turnItInData.rawValue["attachment_1"]?.similarity_score, 0)
        XCTAssertEqual(
            turnItInData.rawValue["attachment_1"]?.outcome_response?.outcomes_tool_placement_url?.rawValue.absoluteString,
            "https://canvas.instructure.com/tool/1"
        )
        XCTAssertEqual(turnItInData.rawValue["submission_1"]?.status, "scored")
    }

    func testDynamicCodingKeysIntInitializer() {
        let codingKey = APITurnItInData.DynamicCodingKeys(intValue: 123)
        XCTAssertNil(codingKey)
    }

    func testRawValueInitializer() {
        let item1 = APITurnItInData.Item(
            status: "scored",
            similarity_score: 85.5,
            outcome_response: .init(outcomes_tool_placement_url: APIURL(rawValue: URL(string: "https://example.com")))
        )
        let item2 = APITurnItInData.Item(
            status: "pending",
            similarity_score: nil,
            outcome_response: nil
        )

        let rawValue = ["attachment_1": item1, "submission_2": item2]
        let turnItInData = APITurnItInData(rawValue: rawValue)

        XCTAssertEqual(turnItInData.rawValue.keys.count, 2)
        XCTAssertEqual(turnItInData.rawValue["attachment_1"]?.status, "scored")
        XCTAssertEqual(turnItInData.rawValue["attachment_1"]?.similarity_score, 85.5)
        XCTAssertEqual(turnItInData.rawValue["submission_2"]?.status, "pending")
        XCTAssertNil(turnItInData.rawValue["submission_2"]?.similarity_score)
        XCTAssertNil(turnItInData.rawValue["submission_2"]?.outcome_response)
    }
}
