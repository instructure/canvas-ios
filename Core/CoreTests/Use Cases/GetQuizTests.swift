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

class GetQuizTest: CoreTestCase {
    let courseID = "1"
    let quizID = "2"

    func testProperties() {
        let useCase = GetQuiz(courseID: courseID, quizID: quizID)
        XCTAssertEqual(useCase.cacheKey, "get-courses-1-quizzes-2")
        XCTAssertEqual(useCase.request.courseID, courseID)
        XCTAssertEqual(useCase.request.quizID, quizID)
        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(Quiz.id), equals: quizID))
    }

    func testWriteNothing() {
        GetQuiz(courseID: courseID, quizID: quizID).write(response: nil, urlResponse: nil, to: databaseClient)
        let quizzes: [Quiz] = databaseClient.fetch()
        XCTAssertEqual(quizzes.count, 0)
    }

    func testWrite() {
        let quiz = APIQuiz.make([ "id": quizID ])
        GetQuiz(courseID: courseID, quizID: quizID).write(response: quiz, urlResponse: nil, to: databaseClient)
        XCTAssertNoThrow(try databaseClient.save())
        let quizzes: [Quiz] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(quizzes.count, 1)
        XCTAssertEqual(quizzes.first?.title, "What kind of pokemon are you?")
        XCTAssertEqual(quizzes.first?.quizType, .survey)
        XCTAssertEqual(quizzes.first?.htmlURL.path, "/courses/1/quizzes/123")
    }
}
