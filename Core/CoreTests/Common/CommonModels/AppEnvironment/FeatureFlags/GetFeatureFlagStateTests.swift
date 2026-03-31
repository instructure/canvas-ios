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

import Foundation
import TestsFoundation
@testable import Core
import XCTest

class GetFeatureFlagStateTests: CoreTestCase {

    func test_request_formation() {
        // Given
        let context = Context(.course, id: "22343")

        // Then
        XCTAssertEqual(
            GetFeatureFlagState(featureName: .assignmentEnhancements, context: context).request.path,
            GetFeatureFlagStateRequest(featureName: .assignmentEnhancements, context: context).path
        )
    }

    func test_writing_state_on() throws {
        // Given
        let context = Context(.course, id: "123")
        let state = APIFeatureFlagState(
            feature: "assignments_2_student",
            state: .on,
            locked: false,
            context_id: "123",
            context_type: "course"
        )

        // When
        let useCase = GetFeatureFlagState(featureName: .assignmentEnhancements, context: context)
        useCase.write(response: state, urlResponse: nil, to: databaseClient)

        // Then 
        let all: [FeatureFlag] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(all.count, 1)

        let flag = try XCTUnwrap(all.first)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag.name, "assignments_2_student")
        XCTAssertEqual(flag.enabled, true)
        XCTAssertEqual(flag.context?.canvasContextID, context.canvasContextID)
    }

    func test_writing_state_off() throws {
        // Given
        let context = Context(.course, id: "123")
        let state = APIFeatureFlagState(
            feature: "assignments_2_student",
            state: .off,
            locked: false,
            context_id: "123",
            context_type: "course"
        )

        // When
        let useCase = GetFeatureFlagState(featureName: .assignmentEnhancements, context: context)
        useCase.write(response: state, urlResponse: nil, to: databaseClient)

        // Then
        let all: [FeatureFlag] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(all.count, 1)

        let flag = try XCTUnwrap(all.first)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag.name, "assignments_2_student")
        XCTAssertEqual(flag.enabled, false)
        XCTAssertEqual(flag.context?.canvasContextID, context.canvasContextID)
    }

    func test_writing_mismatch_contexts() throws {
        // Given
        let context = Context(.course, id: "123")
        let state = APIFeatureFlagState(
            feature: "assignments_2_student",
            state: .allowed_on,
            locked: false,
            context_id: "234",
            context_type: "account"
        )

        // When
        let useCase = GetFeatureFlagState(featureName: .assignmentEnhancements, context: context)
        useCase.write(response: state, urlResponse: nil, to: databaseClient)

        // Then
        let all: [FeatureFlag] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(all.count, 1)

        let flag = try XCTUnwrap(all.first)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag.name, "assignments_2_student")
        XCTAssertEqual(flag.enabled, true)
        XCTAssertEqual(flag.context?.canvasContextID, context.canvasContextID)
    }

    func test_writing_mismatch_contexts_state_off() throws {
        // Given
        let context = Context(.course, id: "123")
        let state = APIFeatureFlagState(
            feature: "assignments_2_student",
            state: .off,
            locked: false,
            context_id: "234",
            context_type: "account"
        )

        // When
        let useCase = GetFeatureFlagState(featureName: .assignmentEnhancements, context: context)
        useCase.write(response: state, urlResponse: nil, to: databaseClient)

        // Then
        let all: [FeatureFlag] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(all.count, 1)

        let flag = try XCTUnwrap(all.first)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag.name, "assignments_2_student")
        XCTAssertEqual(flag.enabled, false)
        XCTAssertEqual(flag.context?.canvasContextID, context.canvasContextID)
    }

    func test_fetching() {
        // Given
        let flag: FeatureFlag = databaseClient.insert()
        flag.name = "assignments_2_student"
        flag.enabled = true
        flag.context = .course("11")

        // WHEN
        let store = environment.subscribe(GetFeatureFlagState(featureName: .assignmentEnhancements, context: .course("11")))

        // THEN
        XCTAssertEqual(store.first?.enabled, true)
    }
}
