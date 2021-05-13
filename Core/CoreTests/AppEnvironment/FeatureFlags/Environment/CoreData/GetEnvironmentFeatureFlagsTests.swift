//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class GetEnvironmentFeatureFlagsTests: CoreTestCase {
    private typealias Model = GetEnvironmentFeatureFlags.Model

    func testWriteCreatesEntityWithDefaultValues() {
        let apiEntity = APIEnvironmentFeatureFlags(canvas_for_elementary: nil)
        let testee = GetEnvironmentFeatureFlags()
        XCTAssertEqual((databaseClient.fetch() as [Model]).count, 0)

        testee.write(response: apiEntity, urlResponse: nil, to: databaseClient)

        XCTAssertEqual((databaseClient.fetch() as [Model]).count, 1)
        guard let model = (databaseClient.fetch() as [Model]).first else { return }
        XCTAssertEqual(model.isCanvasForElementaryEnabled, false)
    }

    func testWriteOverwritesOldEntity() {
        let model = databaseClient.insert() as Model
        model.isCanvasForElementaryEnabled = false
        XCTAssertEqual((databaseClient.fetch() as [Model]).count, 1)
        let apiEntity = APIEnvironmentFeatureFlags(canvas_for_elementary: true)
        let testee = GetEnvironmentFeatureFlags()

        testee.write(response: apiEntity, urlResponse: nil, to: databaseClient)

        XCTAssertEqual((databaseClient.fetch() as [Model]).count, 1)
        XCTAssertEqual(model.isCanvasForElementaryEnabled, true)
    }

    func testUpdateAppEnvironmentFlags() {
        XCTAssertFalse(environment.isK5Enabled)
        let flags = databaseClient.insert() as EnvironmentFeatureFlags
        flags.isCanvasForElementaryEnabled = true

        GetEnvironmentFeatureFlags.updateAppEnvironmentFlags()

        XCTAssertTrue(environment.isK5Enabled)
    }
}
