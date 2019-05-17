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

        let quizzes: [Quiz] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(quizzes.count, 1)
        XCTAssertEqual(quizzes.first?.title, "What kind of pokemon are you?")
        XCTAssertEqual(quizzes.first?.quizType, .survey)
        XCTAssertEqual(quizzes.first?.htmlURL.path, "/courses/1/quizzes/123")
    }

    func testItDeletesQuizzesThatNoLongerExist() {
        let quiz = Quiz.make(["courseID": courseID])
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
