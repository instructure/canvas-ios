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
@testable import Core
import CoreData
import XCTest
import Combine

class InboxSettingsViewModelTests: CoreTestCase {
    private var mockInteractor: InboxSettingsInteractorMock!
    var testee: InboxSettingsViewModel!

    func testOutputValues() {
        mockInteractor = InboxSettingsInteractorMock(environment: environment)
        testee = InboxSettingsViewModel(interactor: mockInteractor, env: environment)

        mockInteractor.setEnvironmentSettings(settings: getEnvironmentSettings(enableSignature: true, disableSignatureForStudent: false))
        mockInteractor.setSettings(inboxSettings: getInboxSettings(useSignature: true, signature: "Test"))

        XCTAssertEqual(true, testee.useSignature)
        XCTAssertEqual("Test", testee.signature)
        XCTAssertEqual(false, testee.enableSaveButton)

        testee.signature = "Test 2"
        testee.useSignature = false

        XCTAssertEqual(false, testee.useSignature)
        XCTAssertEqual("Test 2", testee.signature)
        XCTAssertEqual(true, testee.enableSaveButton)
    }

    private func getInboxSettings(useSignature: Bool, signature: String) -> CDInboxSettings {
        let apiSettings: APIInboxSettings = .make(signature: signature, useSignature: useSignature)
        return CDInboxSettings.save(apiSettings, in: databaseClient)
    }

    private func getEnvironmentSettings(enableSignature: Bool, disableSignatureForStudent: Bool) -> CDEnvironmentSettings {
        let apiSettings = GetEnvironmentSettingsRequest.Response.make(
            enable_inbox_signature_block: enableSignature,
            disable_inbox_signature_block_for_students: disableSignatureForStudent
        )
        return CDEnvironmentSettings.save(apiSettings, in: databaseClient)
    }
}

private class InboxSettingsInteractorMock: InboxSettingsInteractor {
    var refreshCalled = false
    var updateCalled = false
    var state = CurrentValueSubject<Core.StoreState, Never>(.data)
    var signature = CurrentValueSubject<(useSignature: Bool, String?), Never>((false, ""))
    var settings = CurrentValueSubject<Core.CDInboxSettings?, Never>(nil)
    var environmentSettings = CurrentValueSubject<Core.CDEnvironmentSettings?, Never>(nil)
    var isFeatureEnabled = CurrentValueSubject<Bool, Never>(false)
    private var subscriptions = Set<AnyCancellable>()

    init(environment: AppEnvironment) {
        Publishers.CombineLatest(settings, environmentSettings)
            .sink { [weak self, environment] (settings, environmentSettings) in
                guard let settings, let environmentSettings else { return }
                var useSignature = settings.useSignature && environmentSettings.enableInboxSignatureBlock
                if environment.app == .student {
                    useSignature = useSignature && !environmentSettings.disableInboxSignatureBlockForStudents
                }
                self?.signature.send((useSignature, settings.signature))
            }
            .store(in: &subscriptions)
    }

    func updateInboxSettings(inboxSettings: Core.CDInboxSettings) -> AnyPublisher<Void, any Error> {
        updateCalled = true
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func refresh() {
        refreshCalled = true
    }

    func setSettings(inboxSettings: CDInboxSettings) {
        settings.send(inboxSettings)
    }

    func setEnvironmentSettings(settings: CDEnvironmentSettings) {
        environmentSettings.send(settings)
    }

    func setState(newState: StoreState) {
        state.send(newState)
    }
}
