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
import Pendo
import TestsFoundation
import XCTest

class PendoAnalyticsTrackerTests: XCTestCase {

    private var testee: PendoAnalyticsTracker!
    private var interactor: AnalyticsMetadataInteractorMock!
    private var pendoManager: PendoManagerMock!

    override func setUp() {
        super.setUp()
        interactor = .init()
        pendoManager = .init()
        testee = .init(
            interactor: interactor,
            pendoManager: pendoManager,
            pendoApiKey: "some api key"
        )
    }

    override func tearDown() {
        interactor = nil
        pendoManager = nil
        testee = nil
        super.tearDown()
    }

    // MARK: - initManagerWithUrl

    func test_initManager() {
        let url = URL(string: "/some.url")!

        testee.initManager(with: url)

        XCTAssertEqual(pendoManager.initWithUrlCallsCount, 1)
        XCTAssertEqual(pendoManager.initWithUrlInput, url)
    }

    // MARK: - setup

    func test_setup_whenStartWasCalledRepeatedly_shouldBeCalledOnlyOnce() async throws {
        try await testee.startSessionAsync()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)
        XCTAssertEqual(pendoManager.setupInput, "some api key")

        try await testee.startSessionAsync()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)

        try await testee.startSessionAsync()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)
    }

    func test_setup_whenStartAndEndWasCalled_shouldBeCalledOnlyOnce() async throws {
        try await testee.startSessionAsync()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)

        await testee.endSession()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)
    }

    func test_setup_whenEndAndStartWasCalled_shouldBeCalledOnlyOnce() async throws {
        await testee.endSession()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)

        try await testee.startSessionAsync()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)
    }

    func test_setup_whenEndWasCalledRepeatedly_shouldBeCalledOnlyOnce() async throws {
        await testee.endSession()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)
        XCTAssertEqual(pendoManager.setupInput, "some api key")

        await testee.endSession()
        XCTAssertEqual(pendoManager.setupCallsCount, 1)
    }

    // MARK: - start / end

    func test_startSession_shouldCallPendoManagerMethod() async throws {
        let metadata = AnalyticsMetadata.make(
            userId: "some userId",
            accountUUID: "some accountUUID",
            visitorData: .init(id: "some visitor id", locale: "some visitor locale"),
            accountData: .init(id: "some account id", surveyOptOut: true)
        )
        interactor.getMetadataResult = metadata

        try await testee.startSessionAsync()

        XCTAssertEqual(pendoManager.startSessionCallsCount, 1)
        XCTAssertEqual(pendoManager.startSessionInput?.visitorId, metadata.userId)
        XCTAssertEqual(pendoManager.startSessionInput?.accountId, metadata.accountUUID)
        XCTAssertEqual(pendoManager.startSessionInput?.visitorData?["id"] as? String, metadata.visitorData.id)
        XCTAssertEqual(pendoManager.startSessionInput?.visitorData?["locale"] as? String, metadata.visitorData.locale)
        XCTAssertEqual(pendoManager.startSessionInput?.accountData?["id"] as? String, metadata.accountData.id)
        XCTAssertEqual(pendoManager.startSessionInput?.accountData?["surveyOptOut"] as? Bool, metadata.accountData.surveyOptOut)
    }

    @MainActor
    func test_endSession_shouldCallPendoManagerMethod() {
        testee.endSession()

        XCTAssertEqual(pendoManager.endSessionCallsCount, 1)
    }

    // MARK: - track

    func test_track_shouldCallPendoManagerMethod() async throws {
        try await testee.startSessionAsync()

        let properties = ["key1": "value1"]
        testee.track("some event name", properties: properties)

        XCTAssertEqual(pendoManager.trackCallsCount, 1)
        XCTAssertEqual(pendoManager.trackInput?.event, "some event name")
        XCTAssertEqual(pendoManager.trackInput?.properties as? [String: String], properties)
    }

    func test_track_whenCalledDuringSession_shouldTrack() async throws {
        // before session
        testee.track("", properties: nil)
        XCTAssertEqual(pendoManager.trackCallsCount, 0)

        // after session start
        try await testee.startSessionAsync()
        testee.track("", properties: nil)
        XCTAssertEqual(pendoManager.trackCallsCount, 1)

        // called again
        testee.track("", properties: nil)
        XCTAssertEqual(pendoManager.trackCallsCount, 2)

        // after session end
        await testee.endSession()
        testee.track("", properties: nil)
        XCTAssertEqual(pendoManager.trackCallsCount, 2)

        // after session restart
        try await testee.startSessionAsync()
        testee.track("", properties: nil)
        XCTAssertEqual(pendoManager.trackCallsCount, 3)
    }
}


