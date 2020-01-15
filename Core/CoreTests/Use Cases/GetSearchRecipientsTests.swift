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
        let context = ContextModel(.course, id: "1")
        let useCase = GetSearchRecipients(context: context)
        XCTAssertEqual(useCase.cacheKey, "?context=course_1&search=&per_page=50")
    }

    func testRequest() {
        let useCase = GetSearchRecipients(context: ContextModel(.course, id: "1"))
        XCTAssertEqual(useCase.request.path, "search/recipients")
    }

    func testScope() {
        let useCase = GetSearchRecipients(context: ContextModel(.course, id: "1"))
        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(SearchRecipient.filter), equals: "?context=course_1&search=&per_page=50", orderBy: #keyPath(SearchRecipient.fullName)))
    }

    func testFilter() {
        let useCase = GetSearchRecipients(context: ContextModel(.course, id: "1"))
        XCTAssertEqual(useCase.filter, "?context=course_1&search=&per_page=50")
    }

    func testSave() {
        let one = APISearchRecipient.make(id: "1", full_name: "John Doe")
        let two = APISearchRecipient.make(id: "2", full_name: "Jane Doe")

        let useCase = GetSearchRecipients(context: ContextModel(.course, id: "1"))

        useCase.write(response: [one, two], urlResponse: nil, to: databaseClient)

        let results: [SearchRecipient] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first!.id, two.id.value) // Jane
        XCTAssertEqual(results.last!.id, one.id.value) // John
    }
}
