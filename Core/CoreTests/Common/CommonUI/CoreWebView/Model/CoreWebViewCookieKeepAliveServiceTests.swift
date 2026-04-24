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
import Network
import XCTest
@testable import Core

final class CoreWebViewCookieKeepAliveServiceTests: CoreTestCase {

    private var testee: CoreWebViewCookieKeepAliveService!
    private var monitor: NWPathMonitorWrapper!

    private static let sessionURL = URL(string: "data:text/html,")!

    override func setUp() {
        super.setUp()
        monitor = NWPathMonitorWrapper(start: { _ in () }, cancel: {})
        let networkService = NetworkAvailabilityServiceLive(monitor: monitor)
        testee = CoreWebViewCookieKeepAliveService(networkService: networkService)
    }

    override func tearDown() {
        MainActor.assumeIsolated { testee.stop() }
        testee = nil
        monitor = nil
        super.tearDown()
    }

    // MARK: - start

    @MainActor
    func test_start_whenNoAccessToken_shouldNotMakeRequest() {
        environment.api = API(.make(accessToken: nil))
        let notCalledExpectation = expectation(description: "No request made")
        notCalledExpectation.isInverted = true
        api.mock(GetWebSessionRequest(to: nil), dataHandler: { _ in
            notCalledExpectation.fulfill()
            return (nil, nil, nil)
        })

        testee.start(env: environment)

        wait(for: [notCalledExpectation], timeout: 0.5)
    }

    @MainActor
    func test_start_whenAccessTokenPresent_shouldImmediatelyRenewCookies() {
        let requestExpectation = expectation(description: "Session request made")
        api.mock(GetWebSessionRequest(to: nil), dataHandler: { _ in
            requestExpectation.fulfill()
            return (GetWebSessionRequest.Response(
                session_url: Self.sessionURL,
                requires_terms_acceptance: false
            ), nil, nil)
        })

        testee.start(env: environment)

        wait(for: [requestExpectation], timeout: 5)
    }

    @MainActor
    func test_start_whenAlreadyRunning_shouldNotRestart() {
        let requestExpectation = expectation(description: "Session request made")
        requestExpectation.expectedFulfillmentCount = 1
        requestExpectation.assertForOverFulfill = true
        api.mock(GetWebSessionRequest(to: nil), dataHandler: { _ in
            requestExpectation.fulfill()
            return (GetWebSessionRequest.Response(
                session_url: Self.sessionURL,
                requires_terms_acceptance: false
            ), nil, nil)
        })

        testee.start(env: environment)
        testee.start(env: environment)

        wait(for: [requestExpectation], timeout: 5)
    }

    // MARK: - stop

    @MainActor
    func test_stop_shouldPreventFurtherRenewals() {
        let initialRequestExpectation = expectation(description: "Initial request")
        api.mock(GetWebSessionRequest(to: nil), dataHandler: { _ in
            initialRequestExpectation.fulfill()
            return (GetWebSessionRequest.Response(
                session_url: Self.sessionURL,
                requires_terms_acceptance: false
            ), nil, nil)
        })
        testee.start(env: environment)
        wait(for: [initialRequestExpectation], timeout: 5)

        testee.stop()

        let noRequestExpectation = expectation(description: "No request after stop")
        noRequestExpectation.isInverted = true
        api.mock(GetWebSessionRequest(to: nil), dataHandler: { _ in
            noRequestExpectation.fulfill()
            return (nil, nil, nil)
        })
        testee.refresh()
        wait(for: [noRequestExpectation], timeout: 0.5)
    }

    // MARK: - refresh

    @MainActor
    func test_refresh_whenRunning_shouldRenewCookies() {
        var callCount = 0
        let firstCallExpectation = expectation(description: "First request")
        let secondCallExpectation = expectation(description: "Second request from refresh")
        api.mock(GetWebSessionRequest(to: nil), dataHandler: { _ in
            callCount += 1
            if callCount == 1 { firstCallExpectation.fulfill() }
            if callCount == 2 { secondCallExpectation.fulfill() }
            return (GetWebSessionRequest.Response(
                session_url: Self.sessionURL,
                requires_terms_acceptance: false
            ), nil, nil)
        })

        testee.start(env: environment)
        wait(for: [firstCallExpectation], timeout: 5)

        testee.refresh()
        wait(for: [secondCallExpectation], timeout: 5)
    }

    // MARK: - Network status

    @MainActor
    func test_start_whenNetworkComesOnline_shouldRenewCookies() {
        var callCount = 0
        let firstCallExpectation = expectation(description: "Initial renewal")
        let secondCallExpectation = expectation(description: "Renewal after coming online")
        api.mock(GetWebSessionRequest(to: nil), dataHandler: { _ in
            callCount += 1
            if callCount == 1 { firstCallExpectation.fulfill() }
            if callCount == 2 { secondCallExpectation.fulfill() }
            return (GetWebSessionRequest.Response(
                session_url: Self.sessionURL,
                requires_terms_acceptance: false
            ), nil, nil)
        })

        testee.start(env: environment)
        wait(for: [firstCallExpectation], timeout: 5)

        monitor.updateHandler?(NWPathWrapper(status: .unsatisfied, isExpensive: false))
        monitor.updateHandler?(NWPathWrapper(status: .satisfied, isExpensive: false))

        wait(for: [secondCallExpectation], timeout: 5)
    }

    @MainActor
    func test_start_whenNetworkAlreadyConnected_shouldNotFireExtraRenewal() {
        monitor.updateHandler?(NWPathWrapper(status: .satisfied, isExpensive: false))

        let requestExpectation = expectation(description: "Session request made")
        requestExpectation.expectedFulfillmentCount = 1
        requestExpectation.assertForOverFulfill = true
        api.mock(GetWebSessionRequest(to: nil), dataHandler: { _ in
            requestExpectation.fulfill()
            return (GetWebSessionRequest.Response(
                session_url: Self.sessionURL,
                requires_terms_acceptance: false
            ), nil, nil)
        })

        testee.start(env: environment)

        wait(for: [requestExpectation], timeout: 5)
        let noDoubleFireExpectation = expectation(description: "No second request")
        noDoubleFireExpectation.isInverted = true
        wait(for: [noDoubleFireExpectation], timeout: 0.2)
    }
}
