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

class APIQuizRequestableTests: XCTestCase {
    func testGetQuizzesRequest() {
        XCTAssertEqual(GetQuizzesRequest(courseID: "7").path, "courses/7/quizzes?per_page=100")
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
}
