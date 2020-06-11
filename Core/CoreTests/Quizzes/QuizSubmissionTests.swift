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
        XCTAssertTrue(QuizSubmission.make(from: .make(end_at: Date().addDays(1), started_at: Date())).canResume)
        XCTAssertFalse(QuizSubmission.make(from: .make(finished_at: Date().addDays(-1), started_at: Date())).canResume)
        XCTAssertFalse(QuizSubmission.make().canResume)
    }
}
