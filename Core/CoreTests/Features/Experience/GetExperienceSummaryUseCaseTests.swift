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

class GetExperienceSummaryUseCaseTests: CoreTestCase {
    func testCacheKey() {
        let useCase = GetExperienceSummaryUseCase()
        XCTAssertEqual(useCase.cacheKey, "experience-summary")
    }

    func testWrite() {
        let useCase = GetExperienceSummaryUseCase()
        let apiResponse = APIExperienceSummary(
            current_app: .careerLearner,
            available_apps: [.academic, .careerLearner]
        )

        useCase.write(response: apiResponse, urlResponse: nil, to: databaseClient)

        let entities: [CDExperienceSummary] = databaseClient.fetch()
        XCTAssertEqual(entities.count, 1)
        XCTAssertEqual(entities.first?.currentApp, .careerLearner)
        XCTAssertEqual(Set(entities.first?.availableApps ?? []), Set([.academic, .careerLearner]))
    }

    func testWriteWithNilResponse() {
        let useCase = GetExperienceSummaryUseCase()

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let entities: [CDExperienceSummary] = databaseClient.fetch()
        XCTAssertEqual(entities.count, 0)
    }
}
