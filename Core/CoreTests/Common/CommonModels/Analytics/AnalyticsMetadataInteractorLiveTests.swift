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

import Combine
@testable import Core
import TestsFoundation
import XCTest

class AnalyticsMetadataInteractorLiveTests: CoreTestCase {
    func testMappingWhenSurveyFlagIsOff() async throws {
        api.mock(
            GetEnvironmentFeatureFlagsRequest(context: Context.currentUser),
            value: ["account_survey_notifications": false]
        )

        api.mock(
            GetSelfUserIncludingUUIDRequest(),
            value: .make(locale: "en-US", uuid: "1", account_uuid: "2")
        )

        let metadata = try await AnalyticsMetadataInteractorLive().getMetadata()
        print(metadata)
        XCTAssertEqual(metadata.userId, "1".sha256())
        XCTAssertEqual(metadata.accountUUID, "2")
        XCTAssertEqual(metadata.visitorData.id, "1".sha256())
        XCTAssertEqual(metadata.visitorData.locale, "en-US")
        XCTAssertEqual(metadata.accountData.id, "2")
        XCTAssertEqual(metadata.accountData.surveyOptOut, false)
    }

    func testMappingWhenSurveyFlagIsOn() async throws {
        api.mock(
            GetEnvironmentFeatureFlagsRequest(context: Context.currentUser),
            value: ["account_survey_notifications": true]
        )

        api.mock(
            GetSelfUserIncludingUUIDRequest(),
            value: .make(locale: "en-US", uuid: "1", account_uuid: "2")
        )

        let metadata = try await AnalyticsMetadataInteractorLive().getMetadata()
        XCTAssertEqual(metadata.userId, "1".sha256())
        XCTAssertEqual(metadata.accountUUID, "2")
        XCTAssertEqual(metadata.visitorData.id, "1".sha256())
        XCTAssertEqual(metadata.visitorData.locale, "en-US")
        XCTAssertEqual(metadata.accountData.id, "2")
        XCTAssertEqual(metadata.accountData.surveyOptOut, true)
    }
}
