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

class CDExperienceSummaryTests: CoreTestCase {
    func testSave() {
        let apiResponse = APIExperienceSummary(
            current_app: .careerLearner,
            available_apps: [.academic, .careerLearner, .careerLearningProvider]
        )

        let result = CDExperienceSummary.save(apiResponse, in: databaseClient)

        XCTAssertEqual(result.currentApp, .careerLearner)
        XCTAssertEqual(result.currentAppRaw, "career_learner")
        XCTAssertEqual(Set(result.availableApps), Set([.academic, .careerLearner, .careerLearningProvider]))
        XCTAssertEqual(result.availableAppsRaw, Set(["academic", "career_learner", "career_learning_provider"]))
    }

    func testSaveOverwrites() {
        let firstResponse = APIExperienceSummary(
            current_app: .academic,
            available_apps: [.academic]
        )
        let firstResult = CDExperienceSummary.save(firstResponse, in: databaseClient)

        let secondResponse = APIExperienceSummary(
            current_app: .careerLearner,
            available_apps: [.academic, .careerLearner]
        )
        let secondResult = CDExperienceSummary.save(secondResponse, in: databaseClient)

        XCTAssertEqual(firstResult, secondResult)
        XCTAssertEqual(secondResult.currentApp, .careerLearner)
        XCTAssertEqual(Set(secondResult.availableApps), Set([.academic, .careerLearner]))

        let allEntities: [CDExperienceSummary] = databaseClient.fetch()
        XCTAssertEqual(allEntities.count, 1)
    }

    func testUpdate() {
        let apiResponse = APIExperienceSummary(
            current_app: .academic,
            available_apps: [.academic, .careerLearner]
        )
        CDExperienceSummary.save(apiResponse, in: databaseClient)

        CDExperienceSummary.update(experience: "career_learner", in: databaseClient)

        let entities: [CDExperienceSummary] = databaseClient.fetch()
        XCTAssertEqual(entities.count, 1)
        XCTAssertEqual(entities.first?.currentApp, .careerLearner)
        XCTAssertEqual(entities.first?.currentAppRaw, "career_learner")
    }

    func testUpdateWithNoEntity() {
        CDExperienceSummary.update(experience: "academic", in: databaseClient)

        let entities: [CDExperienceSummary] = databaseClient.fetch()
        XCTAssertEqual(entities.count, 0)
    }

    func testCurrentAppDefaultValue() {
        let entity: CDExperienceSummary = databaseClient.insert()
        entity.currentAppRaw = "invalid_experience"

        XCTAssertEqual(entity.currentApp, .academic)
    }

    func testAvailableAppsFiltersInvalidValues() {
        let entity: CDExperienceSummary = databaseClient.insert()
        entity.availableAppsRaw = Set(["academic", "invalid_experience", "career_learner"])

        XCTAssertEqual(Set(entity.availableApps), Set([.academic, .careerLearner]))
    }
}
