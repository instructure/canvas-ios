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

class APILatePolicyRequestableTests: XCTestCase {
    func testCreateLatePolicyRequest() {
        let latePolicy = PostLatePolicyRequest.Body.LatePolicy(
            late_submission_deduction_enabled: true,
            late_submission_deduction: 10,
            late_submission_interval: .day
        )
        let body = PostLatePolicyRequest.Body(late_policy: latePolicy)
        let request = PostLatePolicyRequest(courseID: "1", body: body)

        XCTAssertEqual(request.path, "courses/1/late_policy")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }
}
