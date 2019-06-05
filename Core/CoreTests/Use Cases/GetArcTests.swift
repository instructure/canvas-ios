//
// Copyright (C) 2019-present Instructure, Inc.
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

@testable import Core
import XCTest
import TestsFoundation

class GetArcTests: CoreTestCase {
    let useCase = GetArc(courseID: "1")

    func testRequest() {
        XCTAssertEqual(useCase.request.context.contextType, .course)
        XCTAssertEqual(useCase.request.context.id, "1")
        XCTAssertEqual(useCase.request.perPage, 99)
        XCTAssertTrue(useCase.request.includeParents)
    }

    func testScope() {
        let predicate = useCase.scope.predicate
        XCTAssertTrue(predicate.evaluate(with: ExternalTool.make(from: .make(domain: "arc.instructure.com"), forCourse: "1")))
        XCTAssertFalse(predicate.evaluate(with: ExternalTool.make(from: .make(domain: "bad.instructure.com"), forCourse: "1")))
        XCTAssertFalse(predicate.evaluate(with: ExternalTool.make(from: .make(domain: "arc.instructure.com"), forCourse: "2")))
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "course_1_arc")
    }

    func testWrite() throws {
        let response: [APIExternalTool] = [
            .make(id: "1", domain: "bad.instructure.com"),
            .make(id: "2", domain: "arc.instructure.com"),
        ]
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let results: [ExternalTool] = databaseClient.fetch(useCase.scope.predicate)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, "2")
    }
}
