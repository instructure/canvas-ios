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

import XCTest
@testable import Core

class APIQuizTests: XCTestCase {
    func testQuizAnswerValue() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let recode = { (v: APIQuizAnswerValue) in
            try! decoder.decode(APIQuizAnswerValue.self, from: try! encoder.encode(v))
        }
        XCTAssertEqual(recode(.double(2.2)), .double(2.2))
        XCTAssertEqual(recode(.string("str")), .string("str"))
        XCTAssertEqual(recode(.hash(["key": "value"])), .hash(["key": "value"]))
        XCTAssertEqual(recode(.list(["a", "b"])), .list(["a", "b"]))
        XCTAssertEqual(recode(.matching([["a": "b"], ["c": "d"]])), .matching([["a": "b"], ["c": "d"]]))
    }

    func testGetQuizzesRequest() {
        XCTAssertEqual(GetQuizzesRequest(courseID: "7").path, "courses/7/all_quizzes?per_page=100")
    }

    func testGetQuizRequest() {
        XCTAssertEqual(GetQuizRequest(courseID: "71", quizID: "2").path, "courses/71/quizzes/2")
    }

    func testGetQuizSubmissionRequest() {
        XCTAssertEqual(GetQuizSubmissionRequest(courseID: "45", quizID: "17").path, "courses/45/quizzes/17/submission")
    }

    func testGetAllQuizSubmissionsRequest() {
        XCTAssertEqual(GetAllQuizSubmissionsRequest(courseID: "45", quizID: "17").path, "courses/45/quizzes/17/submissions")
    }

    func testPostQuizSubmissionRequest() {
        let req = PostQuizSubmissionRequest(courseID: "45", quizID: "25", body: .init(access_code: "a", preview: true))
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "courses/45/quizzes/25/submissions")
    }

    func testPostQuizSubmissionCompleteRequest() {
        let req = PostQuizSubmissionCompleteRequest(courseID: "45", quizID: "25", quizSubmissionID: "2", body: .init(attempt: 2, validation_token: "t", access_code: nil))
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "courses/45/quizzes/25/submissions/2/complete")
    }

    func testPutQuizRequest() {
        let quiz = APIQuizParameters(
            access_code: nil,
            allowed_attempts: 5,
            assignment_group_id: nil,
            cant_go_back: nil,
            description: "desc",
            one_question_at_a_time: false,
            published: true,
            quiz_type: .graded_survey,
            scoring_policy: .keep_highest,
            shuffle_answers: false,
            time_limit: 55.0,
            title: "Quiz"
        )

        let expectedBody = PutQuizRequest.Body(quiz: quiz)
        let request = PutQuizRequest(courseID: "1", quizID: "2", body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/quizzes/2")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body, expectedBody)
    }
}
