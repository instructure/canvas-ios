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
        let quiz = APIQuiz.make(id: ID(stringLiteral: quizID))
        QuizSubmission.make(from: .make(quiz_id: ID(stringLiteral: quizID)))
        GetQuiz(courseID: courseID, quizID: quizID).write(response: quiz, urlResponse: nil, to: databaseClient)
        XCTAssertNoThrow(try databaseClient.save())
        let quizzes: [Quiz] = databaseClient.fetch()
        XCTAssertEqual(quizzes.count, 1)
        XCTAssertEqual(quizzes.first?.title, "What kind of pokemon are you?")
        XCTAssertEqual(quizzes.first?.quizType, .survey)
        XCTAssertEqual(quizzes.first?.htmlURL.path, "/courses/1/quizzes/123")
        XCTAssertNotNil(quizzes.first?.submission)
    }
}
