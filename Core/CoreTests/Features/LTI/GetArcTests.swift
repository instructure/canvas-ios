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

@testable import Core
import XCTest
import TestsFoundation

class GetArcTests: CoreTestCase {
    let useCase = GetArc(courseID: "1")

    func testRequest() {
        XCTAssertEqual(useCase.request.context.contextType, .course)
        XCTAssertEqual(useCase.request.context.id, "1")
        XCTAssertEqual(useCase.request.perPage, 100)
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
            .make(id: "2", domain: "arc.instructure.com")
        ]
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let results: [ExternalTool] = databaseClient.fetch(useCase.scope.predicate)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, "2")
    }
}
