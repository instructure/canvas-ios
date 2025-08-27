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

class APISubmissionTests: CoreTestCase {

    func testSubmissionGroupDecode() {
        let json = """
            {
                "id": "28302",
                "assignment_id": "6799",
                "grade_matches_current_submission": true,
                "group": {
                    "id": "284",
                    "name": "Assignment 2"
                },
                "user_id": "12166",
                "workflow_state": "submitted"
            }
        """

        let testee = try? JSONDecoder().decode(APISubmission.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(testee?.group?.id?.value, "284")
        XCTAssertEqual(testee?.group?.name, "Assignment 2")
    }
}
