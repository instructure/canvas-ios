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
import CombineSchedulers
import XCTest
@testable import Core

final class PrivacySettingsViewModelTests: CoreTestCase {

    private var testee: PrivacySettingsViewModel!
    private var interactor: AnalyticsConsentInteractorMock!

    override func setUp() {
        super.setUp()
        interactor = .init()
        testee = .init(interactor: interactor, mainScheduler: .immediate)
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        super.tearDown()
    }

    // MARK: - loadConsent

    func test_loadConsent_whenConsentIsTrue_shouldSetIsAnalyticsEnabledAndDataState() {
        interactor.getConsentIfRequiredResult = true

        testee.loadConsent()

        XCTAssertEqual(testee.isAnalyticsEnabled, true)
        XCTAssertEqual(testee.state, .data)
    }

    func test_loadConsent_whenConsentIsFalse_shouldSetIsAnalyticsEnabledAndDataState() {
        interactor.getConsentIfRequiredResult = false

        testee.loadConsent()

        XCTAssertEqual(testee.isAnalyticsEnabled, false)
        XCTAssertEqual(testee.state, .data)
    }

    func test_loadConsent_whenConsentIsNil_shouldNotTransitionToDataState() {
        interactor.getConsentIfRequiredResult = nil

        testee.loadConsent()

        XCTAssertEqual(testee.state, .loading)
    }

    // MARK: - setAnalyticsConsent (via binding)

    func test_isAnalyticsEnabledBinding_shouldCallInteractorWithProperValue() {
        interactor.getConsentIfRequiredResult = false
        testee.loadConsent()

        testee.isAnalyticsEnabledBinding.wrappedValue = true

        XCTAssertEqual(interactor.setConsentInput, true)
    }

    func test_isAnalyticsEnabledBinding_whenSetConsentSucceeds_shouldKeepNewValue() {
        interactor.getConsentIfRequiredResult = false
        testee.loadConsent()

        testee.isAnalyticsEnabledBinding.wrappedValue = true

        XCTAssertEqual(testee.isAnalyticsEnabled, true)
    }

    func test_isAnalyticsEnabledBinding_whenSetConsentFails_shouldRevertValue() {
        interactor.getConsentIfRequiredResult = false
        testee.loadConsent()
        interactor.setConsentPublisher = Publishers.typedFailure()

        testee.isAnalyticsEnabledBinding.wrappedValue = true

        XCTAssertEqual(testee.isAnalyticsEnabled, false)
    }

    func test_isAnalyticsEnabledBinding_whenSetConsentFails_shouldShowSnackBar() {
        interactor.getConsentIfRequiredResult = false
        testee.loadConsent()
        interactor.setConsentPublisher = Publishers.typedFailure()

        testee.isAnalyticsEnabledBinding.wrappedValue = true

        XCTAssertEqual(testee.snackBar.visibleSnack, "Failed to save setting")
    }
}
