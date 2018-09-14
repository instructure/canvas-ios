//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
@testable import Core

private class TestPaginatedUseCase: PaginatedUseCase<GetCoursesRequest, Course> {
    override var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", "id", "1")
    }

    override func predicate(forItem item: APICourse) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", item.id)
    }

    override func updateModel(_ model: Course, using item: APICourse, in client: Persistence) throws {
        if(model.id.isEmpty) {model.id = item.id}
    }
}

class PaginatedUseCaseTest: CoreTestCase {
    func testItDeletesEverythingMatchingPredicate() {
        self.course(["id": "1"])
        self.course(["id": "2"])
        let request = GetCoursesRequest(includeUnpublished: true)
        api.mock(request, value: nil, response: nil, error: nil)

        let paginated = TestPaginatedUseCase(api: api, database: db, request: request)
        addOperationAndWait(paginated)

        db.refresh()
        let deleted: [Course] = db.fetch(.id("1"))
        let kept: [Course] = db.fetch(.id("2"))
        XCTAssertEqual(deleted.count, 0)
        XCTAssertEqual(kept.count, 1)
    }

    func testItExhaustsPagination() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        let page1 = [APICourse.make(["id": "1", "name": "New Name"]), APICourse.make(["id": "2"])]
        let page2 = [APICourse.make(["id": "3"]), APICourse.make(["id": "4"])]
        let firstPage = GetCoursesRequest(includeUnpublished: true)
        api.mock(firstPage, value: page1, response: response, error: nil)

        let secondPage = GetNextRequest<[APICourse]>(path: next)
        api.mock(secondPage, value: page2, response: nil, error: nil)

        let paginated = TestPaginatedUseCase(api: api, database: db, request: firstPage)
        addOperationAndWait(paginated)

        let courses: [Course] = db.fetch()
        XCTAssertEqual(courses.count, 4)
    }
}
