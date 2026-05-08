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

final class AnalyticsHandlerLiveTests: CoreTestCase {

    private var pendoManager: PendoManagerMock!
    private var consentInteractor: AnalyticsConsentInteractorMock!
    private var testee: AnalyticsHandlerLive!

    override func setUp() {
        super.setUp()
        pendoManager = .init()
        consentInteractor = .init()
        api.mock(GetUserSettingsRequest(userID: "self"), value: .make())
        MainActor.assumeIsolated {
            testee = makeHandler()
        }
    }

    override func tearDown() {
        testee = nil
        consentInteractor = nil
        pendoManager = nil
        super.tearDown()
    }

    // MARK: - initializeTracking

    @MainActor
    func test_initializeTracking_whenTrackingIsEnabled_shouldStartSession() {
        consentInteractor.getTrackingPolicyResult = .trackingEnabled

        let sessionStarted = expectation(description: "session start completion called")
        XCTAssertFinish(testee.initializeTracking(environment: environment) {
            sessionStarted.fulfill()
        })

        wait(for: [sessionStarted], timeout: 2)
        XCTAssertEqual(pendoManager.startSessionCallsCount, 1)
        XCTAssertEqual(pendoManager.endSessionCallsCount, 0)
    }

    @MainActor
    func test_initializeTracking_whenTrackingIsDisabled_shouldEndSession() {
        consentInteractor.getTrackingPolicyResult = .trackingDisabled

        XCTAssertFinish(testee.initializeTracking(environment: environment))

        XCTAssertEqual(pendoManager.endSessionCallsCount, 1)
        XCTAssertEqual(pendoManager.startSessionCallsCount, 0)
    }

    @MainActor
    func test_initializeTracking_whenConsentNeeded_shouldShowConsentDialogAndNotFinish() {
        consentInteractor.getTrackingPolicyResult = .askForConsent

        XCTAssertNoOutput(testee.initializeTracking(environment: environment))

        XCTAssertEqual(pendoManager.endSessionCallsCount, 0)
        XCTAssertEqual(pendoManager.startSessionCallsCount, 0)
    }

    @MainActor
    func test_initializeTracking_shouldSetupPendoManagerExactlyOnce() {
        consentInteractor.getTrackingPolicyResult = .trackingEnabled

        let sessionStarted = expectation(description: "first session start")
        XCTAssertFinish(testee.initializeTracking(environment: environment) { sessionStarted.fulfill() })
        wait(for: [sessionStarted], timeout: 2)

        let sessionStarted2 = expectation(description: "second session start")
        XCTAssertFinish(testee.initializeTracking(environment: environment) { sessionStarted2.fulfill() })
        wait(for: [sessionStarted2], timeout: 2)

        XCTAssertEqual(pendoManager.setupCallsCount, 1)
    }

    @MainActor
    func test_initializeTracking_shouldFetchUserSettings() {
        consentInteractor.getTrackingPolicyResult = .trackingDisabled
        let userSettingsFetched = expectation(description: "GetUserSettings API called")
        api.mock(GetUserSettingsRequest(userID: "self"), expectation: userSettingsFetched, value: .make())

        XCTAssertFinish(testee.initializeTracking(environment: environment))

        wait(for: [userSettingsFetched], timeout: 2)
    }

    // MARK: - storePendoApiKey

    @MainActor
    func test_storePendoApiKey_shouldUseStoredKeyToSetupPendo() {
        testee.storePendoApiKey("some remote key")
        consentInteractor.getTrackingPolicyResult = .trackingEnabled

        let sessionStarted = expectation(description: "session start")
        XCTAssertFinish(testee.initializeTracking(environment: environment) { sessionStarted.fulfill() })
        wait(for: [sessionStarted], timeout: 2)

        XCTAssertEqual(pendoManager.setupInput, "some remote key")
    }

    // MARK: - handleConsentChange

    @MainActor
    func test_handleConsentChange_whenEnabled_shouldStartSession() {
        let sessionStarted = expectation(description: "session start completion called")

        testee.handleConsentChange(to: true) { sessionStarted.fulfill() }

        wait(for: [sessionStarted], timeout: 2)
        XCTAssertEqual(pendoManager.startSessionCallsCount, 1)
        XCTAssertEqual(pendoManager.endSessionCallsCount, 0)
    }

    @MainActor
    func test_handleConsentChange_whenDisabled_shouldEndSession() {
        testee.handleConsentChange(to: false, sessionStartCompletion: { })

        XCTAssertEqual(pendoManager.endSessionCallsCount, 1)
        XCTAssertEqual(pendoManager.startSessionCallsCount, 0)
    }

    // MARK: - endTracking

    @MainActor
    func test_endTracking_shouldCallEndSessionOnTracker() {
        testee.endTracking()

        XCTAssertEqual(pendoManager.endSessionCallsCount, 1)
    }

    // MARK: - handleEvent

    @MainActor
    func test_handleEvent_whenSessionIsInProgress_shouldTrackEvent() {
        startTrackerSession()

        testee.handleEvent("some event", parameters: ["key": "value"])

        XCTAssertEqual(pendoManager.trackCallsCount, 1)
        XCTAssertEqual(pendoManager.trackInput?.event, "some event")
        XCTAssertEqual(pendoManager.trackInput?.properties?["key"] as? String, "value")
    }

    @MainActor
    func test_handleEvent_whenNoSessionIsInProgress_shouldNotTrackEvent() {
        testee.handleEvent("some event", parameters: nil)

        XCTAssertEqual(pendoManager.trackCallsCount, 0)
    }

    // MARK: - handlePendoPairingModeUrl

    @MainActor
    func test_handlePendoPairingModeUrl_whenURLHasPendoScheme_shouldReturnTrueAndInitManager() {
        let url = URL(string: "pendo://some/path")!

        XCTAssertEqual(testee.handlePendoPairingModeUrl(url: url), true)
        XCTAssertEqual(pendoManager.initWithUrlCallsCount, 1)
        XCTAssertEqual(pendoManager.initWithUrlInput, url)
    }

    @MainActor
    func test_handlePendoPairingModeUrl_whenURLDoesNotHavePendoScheme_shouldReturnFalseAndNotInitManager() {
        let url = URL(string: "https://canvas.instructure.com")!

        XCTAssertEqual(testee.handlePendoPairingModeUrl(url: url), false)
        XCTAssertEqual(pendoManager.initWithUrlCallsCount, 0)
    }

    @MainActor
    func test_handlePendoPairingModeUrl_whenURLHasUnrelatedScheme_shouldReturnFalse() {
        let url = URL(string: "canvas://some/path")!

        XCTAssertEqual(testee.handlePendoPairingModeUrl(url: url), false)
        XCTAssertEqual(pendoManager.initWithUrlCallsCount, 0)
    }

    // MARK: - Private helpers

    @MainActor
    private func makeHandler() -> AnalyticsHandlerLive {
        let tracker = PendoAnalyticsTracker(
            interactor: AnalyticsMetadataInteractorMock(),
            pendoManager: pendoManager,
            pendoApiKey: "some-pendo-key"
        )
        return AnalyticsHandlerLive(
            analyticsTracker: tracker,
            consentInteractorProvider: { [consentInteractor] _ in consentInteractor }
        )
    }

    @MainActor
    private func startTrackerSession() {
        consentInteractor.getTrackingPolicyResult = .trackingEnabled
        let sessionStarted = expectation(description: "session started")
        XCTAssertFinish(testee.initializeTracking(environment: environment) { sessionStarted.fulfill() })
        wait(for: [sessionStarted], timeout: 2)
    }
}
