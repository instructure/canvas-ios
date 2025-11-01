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

@testable import Horizon
@testable import Core
import Combine
import XCTest

final class GetHProgramsUseCaseTests: HorizonTestCase {

    private var testee: GetHProgramsUseCase!

    override func setUpWithError() throws {
        testee = GetHProgramsUseCase()
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func testCacheKey() {
        XCTAssertEqual(testee.cacheKey, "get-programs")
    }

    func testMakeRequestSuccess() {
        // Given
        testee = GetHProgramsUseCase(journey: DomainServiceMock(result: .success(api)))
        // When
        let expection = expectation(description: "Wait for completion")
        api.mock(DomainJWTService.JWTTokenRequest(domainServiceOption: .journey), value: DomainJWTService.JWTTokenRequest.Result(token: HProgramStubs.token))
        api.mock(GetHProgramsRequest(), value: HProgramStubs.response)

        // Then
        testee.makeRequest(environment: environment) { response, _, _ in
            expection.fulfill()
            XCTAssertEqual(response?.data?.enrolledPrograms?.count, 6)
        }
        wait(for: [expection], timeout: 0.2)
    }

    func testMakeRequestFail() {
        // Given
        let daomainService = DomainServiceMock(result: .failure(DomainJWTService.Issue.unableToGetToken))
        testee = GetHProgramsUseCase(journey: daomainService)
        // When
        let expection = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .journey),
                value: DomainJWTService.JWTTokenRequest.Result(token: HProgramStubs.token),
               error: DomainJWTService.Issue.unableToGetToken
            )
        api.mock(GetHProgramsRequest(), value: HProgramStubs.response, error: DomainJWTService.Issue.unableToGetToken)

        // Then
        testee.makeRequest(environment: environment) { response, _, error in
            expection.fulfill()
            XCTAssertNil(response?.data)
            XCTAssertEqual(error?.localizedDescription, DomainJWTService.Issue.unableToGetToken.localizedDescription)
        }
        wait(for: [expection], timeout: 0.2)
    }

    func testWriteResponse() {
        // Given
        let response = HProgramStubs.response

        // When
        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let programs: [CDHProgram] = databaseClient.fetch()
        let program = programs.first(where: { $0.id == "d3aaa471-1eb6-4ae7-817a-f0582ea0f806" })
        let sortedRequirements = program?.requirements.sorted { Int(truncating: $0.position) < Int(truncating: $1.position) }
        // Then
        XCTAssertEqual(programs.count, 6)
        XCTAssertEqual(program?.name, "Ahmed Program")
        XCTAssertEqual(sortedRequirements?[0].dependent?.canvasCourseId, "488")
        XCTAssertEqual(sortedRequirements?[1].dependent?.canvasCourseId, "664")
        XCTAssertEqual(sortedRequirements?[2].dependent?.canvasCourseId, "486")
    }
}
