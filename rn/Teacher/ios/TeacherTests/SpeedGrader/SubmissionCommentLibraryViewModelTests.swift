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

    override func setUp() {
        super.setUp()
        let comments = [APICommentLibraryResponse.CommentBankItem(id: "1", comment: "First comment"),
                        APICommentLibraryResponse.CommentBankItem(id: "2", comment: "Second comment") ]
        let response =  APICommentLibraryResponse(data: .init(user: .init(id: "1", commentBankItems: .init(nodes: comments ))))
        api.mock(APICommentLibraryRequest(userId: "1"), value: response)
    }

    func testFechComments() {
        let testee = SubmissionCommentLibraryViewModel()
        testee.viewDidAppear()
        switch testee.state {
        case .data(let comments):
            XCTAssertEqual(comments[0].id, "1")
            XCTAssertEqual(comments[0].text, "First comment")
            XCTAssertEqual(comments[1].id, "2")
            XCTAssertEqual(comments[1].text, "Second comment")
        case .loading, .empty:
            break
        }

    }
}
