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

class GetQuizzesTest: CoreTestCase {
    let courseID = "1"

    func testProperties() {
        let useCase = GetQuizzes(courseID: courseID)
        XCTAssertEqual(useCase.cacheKey, "get-courses-1-quizzes")
        XCTAssertEqual(useCase.request.courseID, courseID)
        XCTAssertEqual(useCase.scope.order.count, 3)
    }

    func testWriteNothing() {
        GetQuizzes(courseID: courseID).write(response: nil, urlResponse: nil, to: databaseClient)
        let quizzes: [Quiz] = databaseClient.fetch()
        XCTAssertEqual(quizzes.count, 0)
    }

    func testItCreatesQuizzes() {
        let groupQuiz = APIQuiz.make()
        let getQuizzes = GetQuizzes(courseID: courseID)
        getQuizzes.write(response: [groupQuiz], urlResponse: nil, to: databaseClient)

        let quizzes: [Quiz] = databaseClient.fetch()
        XCTAssertEqual(quizzes.count, 1)
        XCTAssertEqual(quizzes.first?.title, "What kind of pokemon are you?")
        XCTAssertEqual(quizzes.first?.quizType, .survey)
        XCTAssertEqual(quizzes.first?.htmlURL?.path, "/courses/1/quizzes/123")
    }

    func testItDeletesQuizzesThatNoLongerExist() {
        let quiz = Quiz.make()
        quiz.courseID = courseID
        let request = GetQuizzesRequest(courseID: courseID)
        api.mock(request, value: [], response: nil, error: nil)
        let getQuizzes = GetQuizzes(courseID: courseID)
        let expectation = XCTestExpectation(description: "quizzes written")
        getQuizzes.fetch(environment: environment) { response, urlResponse, _ in
            getQuizzes.write(response: response, urlResponse: urlResponse, to: self.databaseClient)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        databaseClient.refresh()
        let quizzes: [Quiz] = databaseClient.fetch()
        XCTAssertFalse(quizzes.contains(quiz))
    }
}
