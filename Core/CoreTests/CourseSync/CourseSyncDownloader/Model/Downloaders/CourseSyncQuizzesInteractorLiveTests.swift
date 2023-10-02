//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class CourseSyncQuizzesInteractorLiveTests: CoreTestCase {

    func testSuccessfulFetch() {
        mockQuizzes()

        let testee = CourseSyncQuizzesInteractorLive()

        XCTAssertFinish(testee.getContent(courseId: "testCourse"))
        let quizzes: [Quiz] = databaseClient.fetch(scope: .all(orderBy: "id"))
        XCTAssertEqual(quizzes.count, 2)
        XCTAssertEqual(quizzes.first?.id, "testQuiz-1")
        XCTAssertEqual(quizzes.last?.id, "testQuiz-2")
    }

    private func mockQuizzes() {
        api.mock(GetCustomColors(),
                 value: .init(custom_colors: [:]))
        api.mock(GetQuizzes(courseID: "testCourse"),
                 value: [
                    .make(id: "testQuiz-1"),
                    .make(id: "testQuiz-2"),
                 ]
        )

        let getQuiz1 = GetQuizRequest(courseID: "testCourse", quizID: "testQuiz-1")
        let getSubmission1 = GetQuizSubmissionRequest(courseID: "testCourse", quizID: "testQuiz-1")
        let apiQuiz1 = APIQuiz.make(
            access_code: "accessCode",
            assignment_id: "1",
            description: "test description",
            id: "testQuiz-1",
            points_possible: 5,
            published: true,
            time_limit: 10,
            title: "test quiz"
        )
        api.mock(getQuiz1, value: apiQuiz1)
        api.mock(getSubmission1, value: GetQuizSubmissionRequest.Response(quiz_submissions: [.make()]))

        let getQuiz2 = GetQuizRequest(courseID: "testCourse", quizID: "testQuiz-2")
        let getSubmission2 = GetQuizSubmissionRequest(courseID: "testCourse", quizID: "testQuiz-2")
        let apiQuiz2 = APIQuiz.make(
            access_code: "accessCode",
            assignment_id: "1",
            description: "test description",
            id: "testQuiz-2",
            points_possible: 5,
            published: true,
            time_limit: 10,
            title: "test quiz"
        )
        api.mock(getQuiz2, value: apiQuiz2)
        api.mock(getSubmission2, value: GetQuizSubmissionRequest.Response(quiz_submissions: [.make()]))
    }
}
