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

final class GetHSkillUseCaseTests: HorizonTestCase {

    private var testee: GetHSkillsUseCase!

    override func setUpWithError() throws {
        testee = GetHSkillsUseCase()
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func testCacheKey() {
        XCTAssertEqual(testee.cacheKey, "get-skills")
    }

    func testMakeRequestSuccess() {
        // Given
        testee = GetHSkillsUseCase(journey: DomainServiceMock(result: .success(api)))
        // When
        let expection = expectation(description: "Wait for completion")
        api.mock(DomainJWTService.JWTTokenRequest(), value: DomainJWTService.JWTTokenRequest.Result(token: HSkillStubs.token))
        api.mock(GetHSkillRequest(), value: HSkillStubs.response)

        // Then
        testee.makeRequest(environment: environment) { response, _, _ in
            expection.fulfill()
            XCTAssertEqual(response?.data?.skills?.count, 6)
        }
        wait(for: [expection], timeout: 0.2)
    }

    func testMakeRequestFail() {
        // Given
        let daomainService = DomainServiceMock(result: .failure(DomainJWTService.Issue.unableToGetToken))
        testee = GetHSkillsUseCase(journey: daomainService)
        // When
        let expection = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
                value: DomainJWTService.JWTTokenRequest.Result(token: HSkillStubs.token),
               error: DomainJWTService.Issue.unableToGetToken
            )
        api.mock(GetHSkillRequest(), value: HSkillStubs.response, error: DomainJWTService.Issue.unableToGetToken)

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
        let response = HSkillStubs.response

        // When
        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let skills: [CDHSkill] = databaseClient.fetch()
        let skill = skills.first(where: { $0.id == "1" })
        // Then
        XCTAssertEqual(skills.count, 6)
        XCTAssertEqual(skill?.name, "Skill 1")
        XCTAssertEqual(skill?.proficiencyLevel, "expert")
    }

    func testScope() {
        // Given
        let response = HSkillStubs.response
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        // When
        let skills: [CDHSkill] = databaseClient.fetch(scope: testee.scope)

        // Then
        XCTAssertEqual(skills.count, 6)
        XCTAssertEqual(skills[0].name, "Skill 1")
        XCTAssertEqual(skills[1].name, "Skill 2")
        XCTAssertEqual(skills[2].name, "Skill 3")
    }
}
