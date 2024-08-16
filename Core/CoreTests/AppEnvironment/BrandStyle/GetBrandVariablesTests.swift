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

import Combine
import XCTest
import TestsFoundation
@testable import Core

class GetBrandVariablesTest: CoreTestCase {
    let testBundle = Bundle(for: UIImageExtensionsTests.self)
    lazy var testImageURL = testBundle.url(forResource: "TestImage", withExtension: "png")!

    func testFetchesBrandVariables() {
        let testAPIBrandVars: APIBrandVariables = .make(header_image: testImageURL)
        api.mock(GetBrandVariablesRequest(), value: testAPIBrandVars)

        let testee = GetBrandVariables()
        let responseReceived = expectation(description: "Reseponse received")

        var receivedBrandVars: APIBrandVariables?
        var receivedHeaderImageData: Data?

        // WHEN
        testee.makeRequest(environment: environment) { response, _, _ in
            receivedBrandVars = response?.brandVars
            receivedHeaderImageData = response?.headerImage
            responseReceived.fulfill()
        }

        // THEN
        wait(for: [responseReceived])
        XCTAssertEqual(receivedBrandVars, testAPIBrandVars)
        XCTAssertEqual(receivedHeaderImageData, try! Data(contentsOf: testImageURL))
    }

    func testSavesBrandVariables() {
        let testee = GetBrandVariables()
        let testHeaderImageData = Data([123])
        let testAPIBrandVars = APIBrandVariables.make(primary: "test")
        let testResponse = GetBrandVariables.Response(
            brandVars: testAPIBrandVars,
            headerImage: testHeaderImageData
        )
        XCTAssertEqual(databaseClient.first(scope: .all) as CDBrandVariables?, nil)

        // WHEN
        testee.write(
            response: testResponse,
            urlResponse: nil,
            to: databaseClient
        )

        // THEN
        let entities = databaseClient.fetch(scope: testee.scope) as [CDBrandVariables]
        XCTAssertEqual(entities.count, 1)
        let result = entities.first
        XCTAssertEqual(result?.brandVariables?.primary, "test")
        XCTAssertEqual(result?.headerImage, UIImage(data: testHeaderImageData))
    }

    func testCache() {
        let didCallAPI = expectation(description: "didCallAPI")
        api.mock(GetBrandVariablesRequest()) { _ in
            didCallAPI.fulfill()
            return (APIBrandVariables.make(header_image: self.testImageURL, primary: "test"), nil, nil)
        }

        let didReceiveResultFromAPI = expectation(description: "didReceiveResultFromAPI")
        XCTAssertFirstValueAndCompletion(ReactiveStore(useCase: GetBrandVariables()).getEntities()) { results in
            XCTAssertEqual(results.count, 1)
            didReceiveResultFromAPI.fulfill()
        }

        let didReceiveResultFromCache = expectation(description: "didReceiveResultFromCache")
        XCTAssertFirstValueAndCompletion(ReactiveStore(useCase: GetBrandVariables()).getEntities()) { results in
            XCTAssertEqual(results.count, 1)
            didReceiveResultFromCache.fulfill()
        }

        wait(for: [didCallAPI, didReceiveResultFromAPI, didReceiveResultFromCache], timeout: 1)
    }
}
