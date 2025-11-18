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
@testable import Horizon
import TestsFoundation
import XCTest

final class SkillsWidgetInteractorLiveTests: HorizonTestCase {

    func testGetSkills() {
        // Given
        let useCase = GetHSkillsUseCase(journey: DomainServiceMock(result: .success(api)))
        let testee = SkillsWidgetInteractorLive(skillUseCase: useCase)

        // When
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainJWTService.JWTTokenRequest.Result(token: HSkillStubs.token)
        )
        api.mock(GetHSkillRequest(), value: HSkillStubs.response)

        // Then
        XCTAssertSingleOutputAndFinish(testee.getSkills(ignoreCache: true)) { skills in
            XCTAssertEqual(skills.count, 6)
            XCTAssertEqual(skills[0].id, "1")
            XCTAssertEqual(skills[0].title, "Skill 1")
            XCTAssertEqual(skills[0].status, "expert")

            XCTAssertEqual(skills[1].id, "6")
            XCTAssertEqual(skills[1].title, "Skill 6")
            XCTAssertEqual(skills[1].status, "advanced")

            XCTAssertEqual(skills[2].id, "2")
            XCTAssertEqual(skills[2].title, "Skill 2")
            XCTAssertEqual(skills[2].status, "proficient")

            XCTAssertEqual(skills[3].id, "4")
            XCTAssertEqual(skills[3].title, "Skill 4")
            XCTAssertEqual(skills[3].status, "proficient")
        }
    }
}
