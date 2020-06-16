//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class GetEnabledFeatureFlagsTests: CoreTestCase {
    func testScope() {
        let context = Context(.course, id: "1")
        let yes = FeatureFlag.make(context: context)
        let notContext = FeatureFlag.make(context: .course("2"))
        let notEnabled = FeatureFlag.make(context: context, enabled: false)
        let useCase = GetEnabledFeatureFlags(context: context)
        XCTAssertTrue(useCase.scope.predicate.evaluate(with: yes))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: notContext))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: notEnabled))
    }

    func testCacheKey() {
        XCTAssertEqual(GetEnabledFeatureFlags(context: .course("1")).cacheKey, "course_1-enabled-feature-flags")
    }

    func testRequest() {
        let context = Context(.course, id: "1")
        XCTAssertEqual(GetEnabledFeatureFlags(context: context).request.path, GetEnabledFeatureFlagsRequest(context: context).path)
    }

    func testWriteCreates() {
        let context = Context(.course, id: "1")
        let response = ["new_discussions", "no_more_html"]
        let useCase = GetEnabledFeatureFlags(context: context)
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let all: [FeatureFlag] = databaseClient.fetch()
        XCTAssertEqual(all.count, 2)
        let noHTML: FeatureFlag? = databaseClient.first(where: #keyPath(FeatureFlag.name), equals: "no_more_html")
        XCTAssertNotNil(noHTML)
        XCTAssertEqual(noHTML?.name, "no_more_html")
        XCTAssertEqual(noHTML?.enabled, true)
        XCTAssertEqual(noHTML?.context?.canvasContextID, context.canvasContextID)

        let newDiscussions: FeatureFlag? = databaseClient.first(where: #keyPath(FeatureFlag.name), equals: "new_discussions")
        XCTAssertNotNil(newDiscussions)
        XCTAssertEqual(newDiscussions?.name, "new_discussions")
        XCTAssertEqual(newDiscussions?.enabled, true)
        XCTAssertEqual(newDiscussions?.context?.canvasContextID, context.canvasContextID)
    }

    func testWriteUpdates() {
        let context = Context(.course, id: "1")
        let existing = FeatureFlag.make(context: context, name: "new_discussions", enabled: false)
        let response = ["new_discussions", "no_more_html"]
        let useCase = GetEnabledFeatureFlags(context: context)
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        databaseClient.refresh(existing, mergeChanges: true)
        XCTAssertTrue(existing.enabled)
    }

    func testWriteExclusivity() {
        let context = Context(.course, id: "1")
        let other = FeatureFlag.make(context: .course("2"), name: "no_more_html", enabled: false)
        let response = ["new_discussions", "no_more_html"]
        let useCase = GetEnabledFeatureFlags(context: context)
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        databaseClient.refresh(other, mergeChanges: true)
        XCTAssertFalse(other.enabled)
    }
}
