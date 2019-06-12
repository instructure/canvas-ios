//
// Copyright (C) 2019-present Instructure, Inc.
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

class QuizSubmissionTests: CoreTestCase {
    func testWorkflowState() {
        let submission = QuizSubmission.make(from: .make(workflow_state: .complete))
        XCTAssertEqual(submission.workflowState, .complete)
        submission.workflowStateRaw = "invalid$"
        XCTAssertEqual(submission.workflowState, .untaken)
    }

    func testCanResume() {
        XCTAssertTrue(QuizSubmission.make(from: .make(started_at: Date())).canResume)
        XCTAssertTrue(QuizSubmission.make(from: .make(started_at: Date(), end_at: Date().addDays(1))).canResume)
        XCTAssertFalse(QuizSubmission.make(from: .make(started_at: Date(), finished_at: Date().addDays(-1))).canResume)
        XCTAssertFalse(QuizSubmission.make().canResume)
    }
}
