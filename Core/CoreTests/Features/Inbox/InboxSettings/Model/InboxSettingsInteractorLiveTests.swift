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
import XCTest

class InboxSettingsInteractorLiveTests: CoreTestCase {
    private let userId = "1"
    private var testee: InboxSettingsInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    func testEnvironmentFlagDisabledSignatureFlagEnabledResultsFalse() {
        let signatureText = "Test"
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: false, disable_inbox_signature_block_for_students: false)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "signatureLoaded")
        var useSignatureResult: Bool?
        var signatureResult: String?
        var initFlag = false
        testee.signature
            .sink { (useSignature, signature) in
                useSignatureResult = useSignature
                signatureResult = signature
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(false, useSignatureResult)
        XCTAssertEqual(signatureText, signatureResult)
    }

    func testEnvironmentFlagStudentDisabledSignatureFlagEnabledResultsTrueInTeacher() {
        let signatureText = "Test"
        environment.app = .teacher
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: true, disable_inbox_signature_block_for_students: true)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "signatureLoaded")
        var useSignatureResult: Bool?
        var signatureResult: String?
        var initFlag = false
        testee.signature
            .sink { (useSignature, signature) in
                useSignatureResult = useSignature
                signatureResult = signature
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(true, useSignatureResult)
        XCTAssertEqual(signatureText, signatureResult)
    }

    func testEnvironmentFlagStudentDisabledSignatureFlagEnabledResultsTrueInParent() {
        let signatureText = "Test"
        environment.app = .parent
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: true, disable_inbox_signature_block_for_students: true)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "signatureLoaded")
        var useSignatureResult: Bool?
        var signatureResult: String?
        var initFlag = false
        testee.signature
            .sink { (useSignature, signature) in
                useSignatureResult = useSignature
                signatureResult = signature
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(true, useSignatureResult)
        XCTAssertEqual(signatureText, signatureResult)
    }

    func testEnvironmentFlagStudentDisabledSignatureFlagEnabledResultsFalseInStudent() {
        let signatureText = "Test"
        environment.app = .student
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: true, disable_inbox_signature_block_for_students: true)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "signatureLoaded")
        var useSignatureResult: Bool?
        var signatureResult: String?
        var initFlag = false
        testee.signature
            .sink { (useSignature, signature) in
                useSignatureResult = useSignature
                signatureResult = signature
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(false, useSignatureResult)
        XCTAssertEqual(signatureText, signatureResult)
    }

    func testEnvironmentFlagEnabledSignatureFlagDisabledResultsFalse() {
        let signatureText = "Test"
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: true, disable_inbox_signature_block_for_students: false)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: false
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "signatureLoaded")
        var useSignatureResult: Bool?
        var signatureResult: String?
        var initFlag = false
        testee.signature
            .sink { (useSignature, signature) in
                useSignatureResult = useSignature
                signatureResult = signature
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(false, useSignatureResult)
        XCTAssertEqual(signatureText, signatureResult)
    }

    func testEnvironmentFlagEnabledSignatureFlagEnabledResultsTrue() {
        let signatureText = "Test"
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: true, disable_inbox_signature_block_for_students: false)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "signatureLoaded")
        var useSignatureResult: Bool?
        var signatureResult: String?
        var initFlag = false
        testee.signature
            .sink { (useSignature, signature) in
                useSignatureResult = useSignature
                signatureResult = signature
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(true, useSignatureResult)
        XCTAssertEqual(signatureText, signatureResult)
    }

    func testSignatureUpdate() {
        let oldSignatureText = " Old Text"
        let oldUseSignature = false
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: true, disable_inbox_signature_block_for_students: false)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: oldSignatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: oldUseSignature
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let loadExp = expectation(description: "signatureLoaded")
        let updateExp = expectation(description: "signatureUpdated")
        var useSignatureResult: Bool?
        var signatureResult: String?
        var initFlag = false
        var updateFlag = false
        testee.signature
            .sink { (useSignature, signature) in
                useSignatureResult = useSignature
                signatureResult = signature
                if initFlag && !updateFlag {
                    updateFlag = true
                    loadExp.fulfill()
                } else if updateFlag {
                    updateExp.fulfill()
                }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [loadExp], timeout: 1)

        XCTAssertEqual(oldUseSignature, useSignatureResult)
        XCTAssertEqual(oldSignatureText, signatureResult)

        let newSignatureText = "Test"
        let newUseSignature = true
        let newSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: newSignatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: newUseSignature
                )
            )
        )

        let settingsEntity = CDInboxSettings.save(newSettings, in: databaseClient)
        api.mock(
            UpdateInboxSettings(inboxSettings: settingsEntity),
            value: APIUpdateInboxSettings(data: .init(updateMyInboxSettings: newSettings.data))
        )

        _ = testee.updateInboxSettings(inboxSettings: settingsEntity)

        wait(for: [updateExp], timeout: 1)

        XCTAssertEqual(newUseSignature, useSignatureResult)
        XCTAssertEqual(newSignatureText, signatureResult)
    }

    func testFeatureEnabledFlagEnabledForTeacher() {
        let signatureText = "Test"
        environment.app = .teacher
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: true, disable_inbox_signature_block_for_students: true)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "settingsLoaded")
        var isEnabledResult: Bool?
        var initFlag = false
        testee.isFeatureEnabled
            .sink { isEnabled in
                isEnabledResult = isEnabled
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(true, isEnabledResult)
    }

    func testFeatureEnabledFlagDisabledForStudent() {
        let signatureText = "Test"
        environment.app = .student
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: true, disable_inbox_signature_block_for_students: true)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "settingsLoaded")
        var isEnabledResult: Bool?
        var initFlag = false
        testee.isFeatureEnabled
            .sink { isEnabled in
                isEnabledResult = isEnabled
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(false, isEnabledResult)
    }

    func testFeatureEnabledFlagDisabledForTeacher() {
        let signatureText = "Test"
        environment.app = .teacher
        let environmentSettings: GetEnvironmentSettingsRequest.Response = .init(calendar_contexts_limit: 20, enable_inbox_signature_block: false, disable_inbox_signature_block_for_students: true)
        api.mock(GetEnvironmentSettingsRequest(), value: environmentSettings)
        let inboxSettings: APIInboxSettings = .init(
            data: .init(
                myInboxSettings: .init(
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "settingsLoaded")
        var isEnabledResult: Bool?
        var initFlag = false
        testee.isFeatureEnabled
            .sink { isEnabled in
                isEnabledResult = isEnabled
                if initFlag { exp.fulfill() }
                initFlag = true
            }
            .store(in: &subscriptions)
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(false, isEnabledResult)
    }
}
