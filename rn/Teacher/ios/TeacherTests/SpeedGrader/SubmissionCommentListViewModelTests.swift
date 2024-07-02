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
@testable import Teacher
import XCTest

class SubmissionCommentListViewModelTests: TeacherTestCase {
    override func setUp() {
        super.setUp()
        let comments = [
            APICommentLibraryResponse.CommentBankItem(id: "1", comment: "First comment"),
            APICommentLibraryResponse.CommentBankItem(id: "2", comment: "Second comment")
        ]
        let response = APICommentLibraryResponse(data: .init(user: .init(id: "1", commentBankItems: .init(nodes: comments))))
        api.mock(APICommentLibraryRequest(userId: "1"), value: response)
    }

    func testFechComments() {
        let testee = SubmissionCommentLibraryViewModel()
        testee.viewDidAppear()
        switch testee.state {
        case let .data(comments):
            XCTAssertEqual(comments[0].id, "1")
            XCTAssertEqual(comments[0].text, "First comment")
            XCTAssertEqual(comments[1].id, "2")
            XCTAssertEqual(comments[1].text, "Second comment")
        case .loading, .empty:
            break
        }
    }

    func testLoadingState() {
        // WHEN
        let testee = SubmissionCommentListViewModel(
            attempt: nil,
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            scheduler: .immediate
        )

        // THEN
        XCTAssertEqual(testee.state, .loading)
    }

    func testErrorState() {
        // GIVEN
        api.mock(
            GetSubmissionComments(context: .course("1"), assignmentID: "1", userID: "1"),
            error: NSError(domain: "", code: 1)
        )

        // WHEN
        let testee = SubmissionCommentListViewModel(
            attempt: nil,
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            scheduler: .immediate
        )

        // THEN
        XCTAssertEqual(testee.state, .error)
    }

    func testEmptyState() {
        // GIVEN
        api.mock(
            GetSubmissionComments(context: .course("1"), assignmentID: "1", userID: "1"),
            value: .make()
        )
        api.mock(
            GetEnabledFeatureFlags(context: .course("1")),
            value: []
        )

        // WHEN
        let testee = SubmissionCommentListViewModel(
            attempt: nil,
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            scheduler: .immediate
        )

        // THEN
        drainMainQueue()
        XCTAssertEqual(testee.state, .empty)
    }

    func testFlagIsEnabledDataLoadsCommentsAreFiltered() {
        // GIVEN
        api.mock(
            GetSubmissionComments(context: .course("1"), assignmentID: "1", userID: "1"),
            value: .make(
                submission_comments: [
                    .make(id: "1", attempt: 1),
                    .make(id: "2", attempt: 2)
                ]
            )
        )
        api.mock(
            GetEnabledFeatureFlags(context: .course("1")),
            value: ["assignments_2_student"]
        )

        // WHEN
        let testee = SubmissionCommentListViewModel(
            attempt: 2,
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            scheduler: .immediate
        )

        // THEN
        drainMainQueue()
        switch testee.state {
        case .data(let comments):
            XCTAssertEqual(comments.count, 1)
            XCTAssertEqual(comments[0].id, "2")
        default:
            XCTFail("Expected data state")
        }
    }

    func testFlagIsDisabledDataLoadsCommentsAreNotFiltered() {
        // GIVEN
        api.mock(
            GetSubmissionComments(context: .course("1"), assignmentID: "1", userID: "1"),
            value: .make(
                submission_comments: [
                    .make(id: "1", attempt: 1),
                    .make(id: "2", attempt: 2)
                ]
            )
        )
        api.mock(
            GetEnabledFeatureFlags(context: .course("1")),
            value: []
        )

        // WHEN
        let testee = SubmissionCommentListViewModel(
            attempt: 2,
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            scheduler: .immediate
        )

        // THEN
        drainMainQueue()
        switch testee.state {
        case .data(let comments):
            XCTAssertEqual(comments.count, 2)
        default:
            XCTFail("Expected data state")
        }
    }

    func testSpeedGraderAttemptPickerChangedCommentsAreUpdated() {
        // GIVEN
        api.mock(
            GetSubmissionComments(context: .course("1"), assignmentID: "1", userID: "1"),
            value: .make(
                submission_comments: [
                    .make(id: "1", attempt: 1),
                    .make(id: "2", attempt: 2)
                ]
            )
        )
        api.mock(
            GetEnabledFeatureFlags(context: .course("1")),
            value: ["assignments_2_student"]
        )

        // WHEN
        let testee = SubmissionCommentListViewModel(
            attempt: 1,
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            scheduler: .immediate
        )

        drainMainQueue()
        switch testee.state {
        case .data(let comments):
            XCTAssertEqual(comments.count, 1)
            XCTAssertEqual(comments[0].id, "1")
        default:
            XCTFail("Expected data state")
        }
        NotificationCenter.default.post(name: .SpeedGraderAttemptPickerChanged, object: 2)

        // THEN
        switch testee.state {
        case .data(let comments):
            XCTAssertEqual(comments.count, 1)
            XCTAssertEqual(comments[0].id, "2")
        default:
            XCTFail("Expected data state")
        }
    }
}
