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

import XCTest
@testable import Core

class CreateSubmissionTests: CoreTestCase {
    func testItCreatesAssignmentSubmission() {
        //  given
        let submissionType = SubmissionType.online_url
        let context = ContextModel(.course, id: "1")
        let url = URL(string: "http://www.instructure.com")!
        let body = CreateSubmissionRequest.Body.Submission(text_comment: nil, submission_type: submissionType, body: nil, url: url, file_ids: nil, media_comment_id: nil, media_comment_type: nil)
        let request =  CreateSubmissionRequest(context: context, assignmentID: "1", body: .init(submission: body))
        let template: APISubmission = APISubmission.make([
            "assignment_id": "2",
            "grade": "A-",
            "score": 97,
            "late": true,
            "excused": true,
            "missing": true,
            "workflow_state": SubmissionWorkflowState.submitted.rawValue,
            "late_policy_status": LatePolicyStatus.late.rawValue,
            "points_deducted": 10,
            ])

        api.mock(request, value: template, response: nil, error: nil)

        //  when
        let createSubmission = CreateSubmission(context: context, assignmentID: "1", userID: "1", submissionType: submissionType, url: url, env: environment)
        addOperationAndWait(createSubmission)

        //  then
        XCTAssertEqual(createSubmission.errors.count, 0)
        let subs: [Submission] = databaseClient.fetch()
        let submission = subs.first
        XCTAssertNotNil(submission)
        XCTAssertEqual(submission?.grade, "A-")
        XCTAssertEqual(submission?.late, true)
        XCTAssertEqual(submission?.excused, true)
        XCTAssertEqual(submission?.missing, true)
        XCTAssertEqual(submission?.workflowState, .submitted)
        XCTAssertEqual(submission?.latePolicyStatus, .late)
        XCTAssertEqual(submission?.pointsDeducted, 10)
    }
}
