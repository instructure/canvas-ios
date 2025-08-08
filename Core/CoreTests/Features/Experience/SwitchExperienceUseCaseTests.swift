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

class SwitchExperienceUseCaseTests: CoreTestCase {
    func testInitialization() {
        let useCase = SwitchExperienceUseCase(experience: Experience.academic.category)
        XCTAssertNil(useCase.cacheKey)
        XCTAssertEqual(useCase.request.body?.experience, Experience.academic.category)
    }

    func testRequest() {
        let useCase = SwitchExperienceUseCase(experience: Experience.careerLearner.category)
        XCTAssertEqual(useCase.request.body?.experience, Experience.careerLearner.category)
    }

    func testWrite() {
        let apiResponse = APIExperienceSummary(
            current_app: .academic,
            available_apps: [.academic, .careerLearner]
        )
        CDExperienceSummary.save(apiResponse, in: databaseClient)

        let useCase = SwitchExperienceUseCase(experience: Experience.careerLearner.rawValue)
        let responseBody = PostSwitchExperienceRequest.Body(experience: Experience.careerLearner.rawValue)

        useCase.write(response: responseBody, urlResponse: nil, to: databaseClient)

        let entities: [CDExperienceSummary] = databaseClient.fetch()
        XCTAssertEqual(entities.count, 1)
        XCTAssertEqual(entities.first?.currentApp, .careerLearner)
        XCTAssertEqual(entities.first?.currentAppRaw, "career_learner")
    }

    func testWriteWithNilResponse() {
        let apiResponse = APIExperienceSummary(
            current_app: .academic,
            available_apps: [.academic, .careerLearner]
        )
        CDExperienceSummary.save(apiResponse, in: databaseClient)

        let useCase = SwitchExperienceUseCase(experience: Experience.careerLearner.category)

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let entities: [CDExperienceSummary] = databaseClient.fetch()
        XCTAssertEqual(entities.count, 1)
        XCTAssertEqual(entities.first?.currentApp, .academic)
    }
}
