//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import TestsFoundation
import XCTest

class GetModuleTests: CoreTestCase {
    let courseID = "1"
    let moduleID = "2"

    func testRequest() {
        let includes: [GetModulesRequest.Include] = [.items, .content_details]
        let useCase = GetModule(courseID: courseID, moduleID: moduleID, includes: includes)

        XCTAssertEqual(useCase.courseID, courseID)
        XCTAssertEqual(useCase.moduleID, moduleID)
        XCTAssertEqual(useCase.includes, includes)

        let request = useCase.request
        XCTAssertEqual(request.courseID, courseID)
        XCTAssertEqual(request.moduleID, moduleID)
    }

    func testCacheKey() {
        let useCase = GetModule(courseID: courseID, moduleID: moduleID)
        XCTAssertEqual(useCase.cacheKey, "GetModule-\(courseID)-\(moduleID)")
    }

    func testWrite() {
        let useCase = GetModule(courseID: courseID, moduleID: moduleID)
        let apiModule = APIModule.make(id: ID(moduleID))

        useCase.write(response: apiModule, urlResponse: nil, to: databaseClient)

        let modules: [Module] = databaseClient.fetch()
        XCTAssertEqual(modules.count, 1)

        let module = modules.first
        XCTAssertNotNil(module)
        XCTAssertEqual(module?.id, moduleID)
        XCTAssertEqual(module?.courseID, courseID)
    }

    func testWriteNilResponse() {
        let useCase = GetModule(courseID: courseID, moduleID: moduleID)

        _ = Module.save(APIModule.make(id: ID(moduleID)), forCourse: courseID, in: databaseClient)
        let modulesBeforeWrite: [Module] = databaseClient.fetch()
        XCTAssertEqual(modulesBeforeWrite.count, 1)

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let modulesAfterWrite: [Module] = databaseClient.fetch()
        XCTAssertEqual(modulesAfterWrite.count, 1)
    }

    func testInitWithDefaultParameters() {
        let useCase = GetModule(courseID: courseID, moduleID: moduleID)
        XCTAssertEqual(useCase.courseID, courseID)
        XCTAssertEqual(useCase.moduleID, moduleID)
        XCTAssertEqual(useCase.includes, [])
    }

    func testMakeRequest() {
        let useCase = GetModule(courseID: courseID, moduleID: moduleID)
        let apiModule = APIModule.make(id: ID(moduleID))

        api.mock(GetModuleRequest(courseID: courseID, moduleID: moduleID), value: apiModule)

        let expectation = XCTestExpectation(description: "API request completed")
        useCase.makeRequest(environment: environment) { response, _, error in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.id.value, self.moduleID)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testMakeRequestWithIncludes() {
        let includes: [GetModulesRequest.Include] = [.items, .content_details]
        let useCase = GetModule(courseID: courseID, moduleID: moduleID, includes: includes)
        let apiModule = APIModule.make(id: ID(moduleID), items: [
            APIModuleItem.make(id: "1", module_id: ID(moduleID)),
            APIModuleItem.make(id: "2", module_id: ID(moduleID))
        ])

        api.mock(
            GetModuleRequest(
                courseID: courseID,
                moduleID: moduleID
            ),
            value: apiModule,
        )

        let expectation = XCTestExpectation(description: "API request completed")
        useCase.makeRequest(environment: environment) { response, _, error in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.items?.count, 2)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testMakeRequestWithError() {
        let useCase = GetModule(courseID: courseID, moduleID: moduleID)

        api.mock(
            GetModuleRequest(courseID: courseID, moduleID: moduleID),
            value: nil,
            response: nil,
            error: NSError.internalError()
        )

        let expectation = XCTestExpectation(description: "API request completed with error")
        useCase.makeRequest(environment: environment) { response, _, error in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        let modules: [Module] = databaseClient.fetch()
        XCTAssertEqual(modules.count, 0)
    }
}
