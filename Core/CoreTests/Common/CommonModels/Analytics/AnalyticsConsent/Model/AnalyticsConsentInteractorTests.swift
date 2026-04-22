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

    // MARK: - isTrackingEnabled

    func test_isTrackingEnabled_whenSendUsageMetricsFlagIsOff_shouldReturnFalse() {
        mockFeatureFlags(sendUsageMetrics: false, cookieConsentNecessary: false)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isTrackingEnabled(),
            false
        )
    }

    func test_isTrackingEnabled_whenSendUsageMetricsIsOnAndConsentNotRequired_shouldReturnTrue() {
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: false)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isTrackingEnabled(),
            true
        )
    }

    func test_isTrackingEnabled_whenConsentRequiredAndUserAccepted_shouldReturnTrue() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isTrackingEnabled(),
            true
        )
    }

    func test_isTrackingEnabled_whenConsentRequiredAndUserDeclined_shouldReturnFalse() {
        environment.userDefaults?.userProvidedAnalyticsConsent = false
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isTrackingEnabled(),
            false
        )
    }

    func test_isTrackingEnabled_whenConsentRequiredAndNotYetProvided_shouldReturnNil() {
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isTrackingEnabled(),
            nil
        )
    }

    func test_isTrackingEnabled_whenMasqueradingAndConsentRequired_shouldReturnFalse() {
        environment.currentSession = .make(masquerader: URL(string: "/"))
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isTrackingEnabled(),
            false
        )
    }

    func test_isTrackingEnabled_whenMasqueradingAndConsentNotRequired_shouldReturnFalse() {
        environment.currentSession = .make(masquerader: URL(string: "/"))
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: false)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.isTrackingEnabled(),
            false
        )
    }

    // MARK: - getConsentIfRequired

    func test_getConsentIfRequired_whenConsentNotRequired_shouldReturnNil() {
        mockFeatureFlags(sendUsageMetrics: false, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(ignoreCache: true),
            nil
        )
    }

    func test_getConsentIfRequired_whenConsentRequiredAndUserAccepted_shouldReturnTrue() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(ignoreCache: true),
            true
        )
    }

    func test_getConsentIfRequired_whenConsentRequiredAndUserDeclined_shouldReturnFalse() {
        environment.userDefaults?.userProvidedAnalyticsConsent = false
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(ignoreCache: true),
            false
        )
    }

    func test_getConsentIfRequired_whenConsentRequiredAndNotYetProvided_shouldReturnNil() {
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(ignoreCache: true),
            nil
        )
    }

    func test_getConsentIfRequired_whenMasqueradingAndConsentRequired_shouldReturnNil() {
        environment.currentSession = .make(masquerader: URL(string: "/"))
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(ignoreCache: true),
            nil
        )
    }

    func test_getConsentIfRequired_whenMasqueradingAndConsentNotRequired_shouldReturnNil() {
        environment.currentSession = .make(masquerader: URL(string: "/"))
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: false)

        XCTAssertSingleOutputEqualsAndFinish(
            testee.getConsentIfRequired(ignoreCache: true),
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

    func test_isTrackingEnabled_whenSendUsageMetricsFlagIsOff_shouldClearConsentInSessionDefaults() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockFeatureFlags(sendUsageMetrics: false, cookieConsentNecessary: false)

        XCTAssertFinish(testee.isTrackingEnabled())

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, nil)
    }

    func test_isTrackingEnabled_whenConsentNotRequired_shouldClearConsentInSessionDefaults() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: false)

        XCTAssertFinish(testee.isTrackingEnabled())

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, nil)
    }

    func test_isTrackingEnabled_whenConsentRequired_shouldPreserveConsentInSessionDefaults() {
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertFinish(testee.isTrackingEnabled())

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, true)
    }

    func test_isTrackingEnabled_whenMasqueradingAndConsentRequired_shouldClearConsentInSessionDefaults() {
        environment.currentSession = .make(masquerader: URL(string: "/"))
        environment.userDefaults?.userProvidedAnalyticsConsent = true
        mockFeatureFlags(sendUsageMetrics: true, cookieConsentNecessary: true)

        XCTAssertFinish(testee.isTrackingEnabled())

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, nil)
    }

    func test_setConsent_shouldStoreConsentValueInSessionDefaults() {
        XCTAssertNoThrow(try testee.setConsent(true))

        XCTAssertEqual(environment.userDefaults?.userProvidedAnalyticsConsent, true)
    }

    // MARK: - Private helpers

    private func mockFeatureFlags(sendUsageMetrics: Bool, cookieConsentNecessary: Bool) {
        api.mock(
            Self.featureFlagRequest,
            value: [
                "send_usage_metrics": sendUsageMetrics,
                "cookie_consent_necessary": cookieConsentNecessary
            ]
        )
    }
}
