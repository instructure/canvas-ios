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

import Foundation
import XCTest
import TestsFoundation
@testable import Core

class GetBrandVariablesTest: CoreTestCase {

    func testFetchesBrandVariables() {
        let testBundle = Bundle(for: UIImageExtensionsTests.self)
        let testImageURL = testBundle.url(forResource: "TestImage", withExtension: "png")!
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
        let result = databaseClient.first(scope: .all) as CDBrandVariables?
        XCTAssertEqual(result?.brandVariables?.primary, "test")
        XCTAssertEqual(result?.headerImage, UIImage(data: testHeaderImageData))
    }
}
