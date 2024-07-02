//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
@testable import Core
import TestsFoundation

class GetEnvironmentFeatureFlagsTests: CoreTestCase {
    func testScope() {
        let context = Context(.course, id: "1")
        let yes = FeatureFlag.make(context: context, isEnvironmentFlag: true)
        let notContext = FeatureFlag.make(context: .course("2"))
        let environmentFlag = FeatureFlag.make(context: context, isEnvironmentFlag: true)
        let useCase = GetEnvironmentFeatureFlags(context: context)
        XCTAssertTrue(useCase.scope.predicate.evaluate(with: yes))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: notContext))
        XCTAssertTrue(useCase.scope.predicate.evaluate(with: environmentFlag))
    }

    func testCacheKey() {
        XCTAssertEqual(
            GetEnvironmentFeatureFlags(context: .course("1")).cacheKey,
            "course_1-features-environment-json"
        )
    }

    func testRequest() {
        let context = Context(.course, id: "1")
        XCTAssertEqual(
            GetEnabledFeatureFlags(context: context).request.path,
            GetEnabledFeatureFlagsRequest(context: context).path
        )
    }

    func testWriteCreates() {
        let context = Context(.course, id: "1")
        let response = [
            "send_usage_metrics": true,
            "new_discussions": false,
            "react_discussions_post": true
        ]

        // UseCase
        let useCase = GetEnvironmentFeatureFlags(context: context)
        useCase.write(
            response: response,
            urlResponse: nil,
            to: databaseClient
        )
        let all: [FeatureFlag] = databaseClient.fetch()
        XCTAssertEqual(all.count, 3)

        // send_usage_metrics
        let sendUsageMetrics: FeatureFlag? = databaseClient.first(
            where: #keyPath(FeatureFlag.name),
            equals: EnvironmentFeatureFlags.send_usage_metrics.rawValue
        )
        XCTAssertNotNil(sendUsageMetrics)
        XCTAssertEqual(
            sendUsageMetrics?.name,
            EnvironmentFeatureFlags.send_usage_metrics.rawValue
        )
        XCTAssertEqual(
            sendUsageMetrics?.enabled,
            true
        )
        XCTAssertEqual(
            sendUsageMetrics?.context?.canvasContextID,
            context.canvasContextID
        )

        // new_discussions
        let newDiscussions: FeatureFlag? = databaseClient.first(
            where: #keyPath(FeatureFlag.name),
            equals: "new_discussions"
        )
        XCTAssertNotNil(newDiscussions)
        XCTAssertEqual(
            newDiscussions?.name,
            "new_discussions"
        )
        XCTAssertEqual(
            newDiscussions?.enabled,
            false
        )
        XCTAssertEqual(
            newDiscussions?.context?.canvasContextID,
            context.canvasContextID
        )

        // react_discussion
        let reactDiscussionsPost: FeatureFlag? = databaseClient.first(
            where: #keyPath(FeatureFlag.name),
            equals: "react_discussions_post"
        )
        XCTAssertNotNil(reactDiscussionsPost)
        XCTAssertEqual(
            reactDiscussionsPost?.name,
            "react_discussions_post"
        )
        XCTAssertEqual(
            reactDiscussionsPost?.enabled,
            true
        )
        XCTAssertEqual(
            reactDiscussionsPost?.context?.canvasContextID,
            context.canvasContextID
        )
    }

    func testWriteUpdates() {
        let context = Context(.course, id: "1")
        let existing = FeatureFlag.make(
            context: context,
            name: "new_discussions",
            enabled: false
        )
        let response = [
            "send_usage_metrics": false,
            "new_discussions": true
        ]
        let useCase = GetEnvironmentFeatureFlags(context: context)
        useCase.write(
            response: response,
            urlResponse: nil,
            to: databaseClient
        )
        databaseClient.refresh(
            existing,
            mergeChanges: true
        )
        XCTAssertTrue(existing.enabled)
    }

    func testWriteExclusivity() {
        let context = Context(.course, id: "1")
        let other = FeatureFlag.make(
            context: .course("2"),
            name: "send_usage_metrics",
            enabled: false
        )
        let response = [
            "send_usage_metrics": true,
            "new_discussions": false
        ]
        let useCase = GetEnvironmentFeatureFlags(context: context)
        useCase.write(
            response: response,
            urlResponse: nil,
            to: databaseClient
        )
        databaseClient.refresh(
            other,
            mergeChanges: true
        )
        XCTAssertFalse(other.enabled)
    }
}
