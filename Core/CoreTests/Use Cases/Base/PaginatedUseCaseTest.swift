//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

    override func updateModel(_ model: Course, using item: APICourse, in client: PersistenceClient) throws {
        model.id = item.id
    }
}

class PaginatedUseCaseTest: CoreTestCase {
    func testItDeletesEverythingMatchingPredicate() {
        Course.make(["id": "1"])
        Course.make(["id": "2"])
        let request = GetCoursesRequest(includeUnpublished: true)
        api.mock(request, value: nil, response: nil, error: nil)

        let paginated = TestPaginatedUseCase(api: api, database: database, request: request)
        addOperationAndWait(paginated)

        let deleted: [Course] = databaseClient.fetch(NSPredicate(format: "%K == %@", #keyPath(Course.id), "1"))
        let kept: [Course] = databaseClient.fetch(NSPredicate(format: "%K == %@", #keyPath(Course.id), "2"))
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

        let paginated = TestPaginatedUseCase(api: api, database: database, request: firstPage)
        addOperationAndWait(paginated)

        let courses: [Course] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 4)
    }
}
