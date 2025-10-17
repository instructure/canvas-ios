//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class UpdateDiscussionReplyTests: CoreTestCase {
    let context = Context(.course, id: "1")

    func testUpdateDiscussionReply() {
        let useCase = UpdateDiscussionReply(context: context, topicID: "2", entryID: "1", message: "updated")
        XCTAssertNil(useCase.cacheKey)
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        let reply = DiscussionEntry.make()
        useCase.write(response: .make(message: "updated"), urlResponse: nil, to: databaseClient)
        XCTAssertEqual(reply.message, "updated")
    }
}
