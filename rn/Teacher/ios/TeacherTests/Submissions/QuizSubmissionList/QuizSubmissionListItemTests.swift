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

import XCTest
@testable import Core
@testable import Teacher

class QuizSubmissionListItemTests: TeacherTestCase {

    func testArrayGeneration() {
        let user = QuizSubmissionUser.save(APIUser.make(id: 1, name: "John", avatar_url: URL(string: "https://example.com/avatar1"), pronouns: "he/him"), in: databaseClient)
        let users = [user, QuizSubmissionUser.make(in: databaseClient)]
        let submissions: [QuizSubmission] = [.make()]
        let testee = QuizSubmissionListItem.make(users: users, submissions: submissions)

        XCTAssertEqual(testee.count, 2)
        XCTAssertEqual(testee[0].id, "1")
        XCTAssertEqual(testee[0].displayName, "John (he/him)")
        XCTAssertEqual(testee[0].name, "John")
        XCTAssertEqual(testee[0].status, .untaken)
        XCTAssertNil(testee[0].score)
        XCTAssertEqual(testee[0].avatarURL, user.avatarURL)

    }

    func testConnectSubmissions() {
        let users = [QuizSubmissionUser.make(id: "1", in: databaseClient), QuizSubmissionUser.make(id: "2", in: databaseClient)]
        let submissions = [QuizSubmission.make(from: .make(score: 99, user_id: "1", workflow_state: .complete))]
        let testee = QuizSubmissionListItem.make(users: users, submissions: submissions)

        XCTAssertEqual(testee[0].status, .complete)
        XCTAssertEqual(testee[0].score, "99")
        XCTAssertEqual(testee[1].status, .untaken)
        XCTAssertNil(testee[1].score)
    }

    func testApplyFilter() {
        let array: [QuizSubmissionListItem] = [
            QuizSubmissionListItem(id: "1", displayName: "Complete", name: "Complete", status: .complete, score: "5", avatarURL: nil),
            QuizSubmissionListItem(id: "2", displayName: "Untaken", name: "Untaken", status: .untaken, score: "5", avatarURL: nil),
            QuizSubmissionListItem(id: "3", displayName: "Preview", name: "Preview", status: .preview, score: "5", avatarURL: nil),
        ]
        XCTAssertEqual(array.applyFilter(filter: .all).count, 3)
        XCTAssertEqual(array.applyFilter(filter: .submitted).count, 1)
        XCTAssertEqual(array.applyFilter(filter: .submitted).first?.name, "Complete")
        XCTAssertEqual(array.applyFilter(filter: .notSubmitted).count, 2)
    }

    func testScoreTruncation() {
        let users = [QuizSubmissionUser.make(id: "1", in: databaseClient), QuizSubmissionUser.make(id: "2", in: databaseClient)]
        let submissions = [
            QuizSubmission.make(from: .make(id: "1", score: 2.66667, user_id: "1", workflow_state: .complete)),
            QuizSubmission.make(from: .make(id: "2", score: 1.00001, user_id: "2", workflow_state: .complete)),
        ]
        let testee = QuizSubmissionListItem.make(users: users, submissions: submissions)

        XCTAssertEqual(testee[0].score, "2.67")
        XCTAssertEqual(testee[1].score, "1")
    }
}
