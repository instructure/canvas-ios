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
@testable import Core
import XCTest

class APIConversationRecipientTests: CoreTestCase {
    func testGetConversationRecipientsRequest() {
        XCTAssertEqual(GetConversationRecipientsRequest(search: "q").path, "search/recipients")
        XCTAssertEqual(GetConversationRecipientsRequest(search: "q").query, [
            .value("per_page", "10"),
            .value("search", "q"),
            .value("synthetic_contexts", "1"),
            .value("type", "user"),
        ])
        XCTAssertEqual(GetConversationRecipientsRequest(search: "q", context: "course_1", includeContexts: true).query, [
            .value("per_page", "10"),
            .value("search", "q"),
            .value("synthetic_contexts", "1"),
            .value("context", "course_1"),
        ])
    }
}
