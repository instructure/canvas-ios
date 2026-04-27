//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import XCTest
@testable import Core
import TestsFoundation

final class AnalyticsConsentInteractorLiveTests: CoreTestCase {

    private static let featureFlagRequest = GetEnvironmentFeatureFlagsRequest(context: .currentUser)
    private static let userSettingsRequest = GetUserSettingsRequest(userID: "self")

    private var testee: AnalyticsConsentInteractorLive!

    override func setUp() {
        super.setUp()
        environment.app = .student
        testee = .init(environment: environment)
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - getTrackingPolicy

    func test_getTrackingPolicy_whenUserSettingsHasTrackingEnabled_shouldReturnTrackingEnabled() {
        mockUserSettings(usageMetrics: "track_usage")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getTrackingPolicy(ignoreCache: false),
            .trackingEnabled
        )
    }

    func test_getTrackingPolicy_whenUserSettingsHasTrackingDisabled_shouldReturnTrackingDisabled() {
        mockUserSettings(usageMetrics: "no_track_usage")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getTrackingPolicy(ignoreCache: false),
            .trackingDisabled
        )
    }

    func test_getTrackingPolicy_whenConsentRequiredAndUserAccepted_shouldReturnTrackingEnabled() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockUserSettings(usageMetrics: "ask_for_consent")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getTrackingPolicy(ignoreCache: false),
            .trackingEnabled
        )
    }

    func test_getTrackingPolicy_whenConsentRequiredAndUserDeclined_shouldReturnTrackingDisabled() {
        environment.userDefaults?.userProvidedAnalyticsConsent = false
        mockUserSettings(usageMetrics: "ask_for_consent")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getTrackingPolicy(ignoreCache: false),
            .trackingDisabled
        )
    }

    func test_getTrackingPolicy_whenConsentRequiredAndNotYetProvided_shouldReturnAskForConsent() {
        mockUserSettings(usageMetrics: "ask_for_consent")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getTrackingPolicy(ignoreCache: false),
            .askForConsent
        )
    }

    func test_getTrackingPolicy_whenUserSettingsHasNoTrackingPolicyAndLegacyFlagIsOn_shouldReturnTrackingEnabled() {
        mockUserSettings(usageMetrics: nil)
        mockFeatureFlags(sendUsageMetrics: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getTrackingPolicy(ignoreCache: false),
            .trackingEnabled
        )
    }

    func test_getTrackingPolicy_whenUserSettingsHasNoTrackingPolicyAndLegacyFlagIsOff_shouldReturnTrackingDisabled() {
        mockUserSettings(usageMetrics: nil)
        mockFeatureFlags(sendUsageMetrics: false)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getTrackingPolicy(ignoreCache: false),
            .trackingDisabled
        )
    }

    func test_getTrackingPolicy_whenMasquerading_shouldReturnTrackingDisabled() {
        environment.currentSession = .make(masquerader: URL(string: "/"))

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getTrackingPolicy(ignoreCache: false),
            .trackingDisabled
        )
    }

    // MARK: - isConsentRequired

    func test_isConsentRequired_whenUserSettingsHasAskForConsent_shouldReturnTrue() {
        mockUserSettings(usageMetrics: "ask_for_consent")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isConsentRequired(ignoreCache: false),
            true
        )
    }

    func test_isConsentRequired_whenUserSettingsHasTrackingEnabled_shouldReturnFalse() {
        mockUserSettings(usageMetrics: "track_usage")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isConsentRequired(ignoreCache: false),
            false
        )
    }

    func test_isConsentRequired_whenUserSettingsHasTrackingDisabled_shouldReturnFalse() {
        mockUserSettings(usageMetrics: "no_track_usage")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isConsentRequired(ignoreCache: false),
            false
        )
    }

    func test_isConsentRequired_whenMasquerading_shouldReturnFalse() {
        environment.currentSession = .make(masquerader: URL(string: "/"))

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isConsentRequired(ignoreCache: false),
            false
        )
    }

    // MARK: - getConsentIfRequired

    func test_getConsentIfRequired_whenConsentRequiredAndUserAccepted_shouldReturnTrue() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockUserSettings(usageMetrics: "ask_for_consent")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(),
            true
        )
    }

    func test_getConsentIfRequired_whenConsentRequiredAndUserDeclined_shouldReturnFalse() {
        environment.userDefaults?.userProvidedAnalyticsConsent = false
        mockUserSettings(usageMetrics: "ask_for_consent")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(),
            false
        )
    }

    func test_getConsentIfRequired_whenConsentRequiredAndNotYetProvided_shouldReturnNil() {
        mockUserSettings(usageMetrics: "ask_for_consent")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(),
            nil
        )
    }

    func test_getConsentIfRequired_whenConsentNotRequired_shouldReturnNil() {
        mockUserSettings(usageMetrics: "track_usage")

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(),
            nil
        )
    }

    func test_getConsentIfRequired_whenMasquerading_shouldReturnNil() {
        environment.currentSession = .make(masquerader: URL(string: "/"))

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(),
            nil
        )
    }

    // MARK: - setConsent

    func test_setConsent_shouldNotThrow() {
        XCTAssertNoThrow(try testee.setConsent(true))
    }

    func test_setConsent_whenMasquerading_shouldThrow() {
        environment.currentSession = .make(masquerader: URL(string: "/"))

        XCTAssertThrowsError(try testee.setConsent(true))
    }

    // MARK: - Storing consent in session defaults

    func test_getTrackingPolicy_whenPredefinedPolicy_shouldClearConsentInSessionDefaults() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockUserSettings(usageMetrics: "track_usage")

        XCTAssertFinish(testee.getTrackingPolicy(ignoreCache: false))

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, nil)
    }

    func test_getTrackingPolicy_whenConsentRequired_shouldPreserveConsentInSessionDefaults() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockUserSettings(usageMetrics: "ask_for_consent")

        XCTAssertFinish(testee.getTrackingPolicy(ignoreCache: false))

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, true)
    }

    func test_getTrackingPolicy_whenMasquerading_shouldClearConsentInSessionDefaults() {
        environment.currentSession = .make(masquerader: URL(string: "/"))
        environment.userDefaults?.userProvidedAnalyticsConsent = true

        XCTAssertFinish(testee.getTrackingPolicy(ignoreCache: false))

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, nil)
    }

    func test_setConsent_shouldStoreConsentValueInSessionDefaults() {
        XCTAssertNoThrow(try testee.setConsent(true))

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, true)
    }

    // MARK: - Private helpers

    private func mockUserSettings(usageMetrics: String?) {
        api.mock(
            Self.userSettingsRequest,
            value: .make(usage_metrics: usageMetrics)
        )
    }

    private func mockFeatureFlags(sendUsageMetrics: Bool) {
        api.mock(
            Self.featureFlagRequest,
            value: ["send_usage_metrics": sendUsageMetrics]
        )
    }
}
