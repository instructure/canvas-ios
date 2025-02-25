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
                    _id: "1",
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true,
                    userId: userId
                )
            )
        )
        api.mock(GetInboxSettingsRequest(), value: inboxSettings)

        testee = InboxSettingsInteractorLive(userId: userId, environment: environment)

        let exp = expectation(description: "signatureLoaded")
        var useSignatureResult: Bool? = nil
        var signatureResult: String? = nil
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
                    _id: "1",
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true,
                    userId: userId
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
                    _id: "1",
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true,
                    userId: userId
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
                    _id: "1",
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true,
                    userId: userId
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
                    _id: "1",
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: false,
                    userId: userId
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
                    _id: "1",
                    createdAt: nil,
                    outOfOfficeLastDate: nil,
                    outOfOfficeMessage: nil,
                    outOfOfficeSubject: nil,
                    outOfOfficeFirstDate: nil,
                    signature: signatureText,
                    updatedAt: nil,
                    useOutOfOffice: nil,
                    useSignature: true,
                    userId: userId
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
}
