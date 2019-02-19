//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core

class APIAssignmentOverrideRequestableTests: XCTestCase {
    func testCreateAssignmentOverrideRequest() {
        let override = CreateAssignmentOverrideRequest.Body.AssignmentOverride(title: "a")
        let expectedBody = CreateAssignmentOverrideRequest.Body(assignment_override: override)
        let request = CreateAssignmentOverrideRequest(courseID: "1", assignmentID: "2", body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/assignments/2/overrides")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, expectedBody)
    }
}
