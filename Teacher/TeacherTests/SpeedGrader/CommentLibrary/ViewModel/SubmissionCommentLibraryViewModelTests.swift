//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class SubmissionCommentLibraryViewModelTests: TeacherTestCase {

    func testFetchComments() {
        // Given
        api.mock(GetUserSettingsRequest(userID: "self"),
                 value: APIUserSettings.make(comment_library_suggestions_enabled: true))

        let comments = [APICommentLibraryResponse.CommentBankItem(id: "1", comment: "First comment"),
                        APICommentLibraryResponse.CommentBankItem(id: "2", comment: "Second comment") ]
        let response =  APICommentLibraryResponse(
            data: .init(
                user: .init(
                    id: "1",
                    commentBankItems: .init(
                        nodes: comments,
                        pageInfo: APIPageInfo(endCursor: "next_cursor", hasNextPage: true)
                    )
                )
            )
        )
        api.mock(APICommentLibraryRequest(userId: "1"), value: response)

        // When
        let testee = CommentLibraryViewModel()

        let exp1 = expectation(description: "fetch completed")
        testee.viewDidAppear(completion: { exp1.fulfill() })

        wait(for: [exp1], timeout: 2)

        // Then
        XCTAssertEqual(testee.endCursor, "next_cursor")

        guard case .data(let loaded) = testee.state  else {
            XCTFail("Data state expected!")
            return
        }

        XCTAssertEqual(loaded[0].id, "1")
        XCTAssertEqual(loaded[0].text, "First comment")
        XCTAssertEqual(loaded[1].id, "2")
        XCTAssertEqual(loaded[1].text, "Second comment")

        // MARK: - Loading Next Page

        // Given
        let nextPage = [APICommentLibraryResponse.CommentBankItem(id: "3", comment: "Third comment"),
                        APICommentLibraryResponse.CommentBankItem(id: "4", comment: "Fourth comment") ]
        let pageResponse =  APICommentLibraryResponse(
            data: .init(
                user: .init(
                    id: "1",
                    commentBankItems: .init(
                        nodes: nextPage,
                        pageInfo: APIPageInfo(endCursor: "finish_cursor", hasNextPage: false)
                    )
                )
            )
        )
        api.mock(APICommentLibraryRequest(userId: "1", cursor: "next_cursor"), value: pageResponse)

        // When
        let exp2 = expectation(description: "page loaded")
        testee.loadNextPage(completion: { exp2.fulfill() })

        wait(for: [exp2], timeout: 2)

        // Then
        XCTAssertNil(testee.endCursor)

        guard case .data(let loaded) = testee.state  else {
            XCTFail("Data state expected!")
            return
        }

        let expected = (comments + nextPage).map({ LibraryComment(id: $0.id, text: $0.comment) })
        XCTAssertEqual(loaded, expected)
    }
}
