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

class DeleteDiscussionEntryRequestTests: XCTestCase {
    let context = Context(.course, id: "1")

    func testDeleteDiscussionEntryRequest() {
        let request = DeleteDiscussionEntryRequest(context: context, topicID: "1", entryID: "1")
        XCTAssertEqual(request.method, .delete)
        XCTAssertEqual(request.path, "courses/1/discussion_topics/1/entries/1")
    }
}
