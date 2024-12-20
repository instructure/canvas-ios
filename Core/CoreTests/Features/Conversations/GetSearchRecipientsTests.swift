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

class GetSearchRecipientsTests: CoreTestCase {
    func testCacheKey() {
        let context = Context(.course, id: "1")
        let useCase = GetSearchRecipients(context: context)
        XCTAssertEqual(useCase.cacheKey, "per_page=50&context=course_1&search=&synthetic_contexts=1&type=user")
    }

    func testRequest() {
        let useCase = GetSearchRecipients(context: .course("1"))
        XCTAssertEqual(useCase.request.path, "search/recipients")
    }

    func testScope() {
        let useCase = GetSearchRecipients(context: .course("1"))
        XCTAssertEqual(useCase.scope, Scope.where(
            #keyPath(SearchRecipient.filter),
            equals: "per_page=50&context=course_1&search=&synthetic_contexts=1&type=user",
            orderBy: #keyPath(SearchRecipient.name), naturally: true
        ))
    }

    func testFilter() {
        let useCase = GetSearchRecipients(context: .course("1"))
        XCTAssertEqual(useCase.filter, "per_page=50&context=course_1&search=&synthetic_contexts=1&type=user")
    }

    func testSave() {
        let one = APISearchRecipient.make(id: "1", name: "John")
        let two = APISearchRecipient.make(id: "2", name: "Jane")

        let useCase = GetSearchRecipients(context: .course("1"))

        useCase.write(response: [one, two], urlResponse: nil, to: databaseClient)

        let results: [SearchRecipient] = databaseClient.fetch(scope: useCase.scope)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first!.id, two.id.value) // Jane
        XCTAssertEqual(results.last!.id, one.id.value) // John
    }
}
