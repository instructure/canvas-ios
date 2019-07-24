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

class GetQuizSubmissionsTest: CoreTestCase {
    let courseID = "1"
    let quizID = "2"

    func testProperties() {
        let useCase = GetQuizSubmissions(courseID: courseID, quizID: quizID)
        XCTAssertEqual(useCase.cacheKey, "get-courses-1-quizzes-2-submissions")
        XCTAssertEqual(useCase.request.courseID, courseID)
        XCTAssertEqual(useCase.request.quizID, quizID)
        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(QuizSubmission.quizID), equals: quizID, orderBy: #keyPath(QuizSubmission.attempt), ascending: false))
    }

    func testWriteNothing() {
        GetQuizSubmissions(courseID: courseID, quizID: quizID).write(response: nil, urlResponse: nil, to: databaseClient)
        let submissions: [QuizSubmission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 0)
    }

    func testWrite() {
        let id = ID(stringLiteral: quizID)
        Quiz.make(from: APIQuiz.make(id: id), courseID: courseID)
        let useCase = GetQuizSubmissions(courseID: courseID, quizID: quizID)
        useCase.write(response: .init(quiz_submissions: [
            APIQuizSubmission.make(quiz_id: id),
            APIQuizSubmission.make(attempt: 2, id: "2", quiz_id: id),
        ]), urlResponse: nil, to: databaseClient)
        XCTAssertNoThrow(try databaseClient.save())
        let submissions: [QuizSubmission] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)
        XCTAssertEqual(submissions.count, 2)
        XCTAssertEqual(submissions.first?.attempt, 2)
        XCTAssertEqual(submissions.first?.workflowState, .untaken)
        XCTAssertNotNil(submissions.first?.quiz)
    }
}
