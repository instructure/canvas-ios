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

@testable import Core
import Foundation
import TestsFoundation
import XCTest

class AVPermissionViewModelTests: CoreTestCase {

    private var interactor: AVPermissionInteractorMock!
    private var loginDelegate: TestLoginDelegate!
    private var sourceVC: UIViewController!
    private var testee: AVPermissionViewModel!

    override func setUp() {
        super.setUp()
        interactor = .init()
        loginDelegate = .init()
        sourceVC = .init()
        testee = .init(
            interactor: interactor,
            env: environment
        )

        environment.loginDelegate = loginDelegate
    }

    override func tearDown() {
        interactor = nil
        loginDelegate = nil
        sourceVC = nil
        testee = nil
        super.tearDown()
    }

    // MARK: - Camera permission

    func test_performAfterCameraPermission_whenPermitted_shouldCallAction() {
        interactor.isCameraPermitted = true
        var actionCallsCount = 0

        testee.performAfterCameraPermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 1)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 0)
        XCTAssertEqual(router.lastViewController, nil)
    }

    func test_performAfterCameraPermission_whenNotPermitted_shouldShowError() throws {
        interactor.isCameraPermitted = false
        var actionCallsCount = 0

        testee.performAfterCameraPermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 1)

        try verifyLastShownAlertController(messagePart: "camera")
    }

    func test_performAfterCameraPermission_whenPermissionIsNil_shouldRequestPermission() throws {
        interactor.isCameraPermitted = nil
        var actionCallsCount = 0

        testee.performAfterCameraPermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 1)
        XCTAssertEqual(router.viewControllerCalls.count, 0)
    }

    func test_performAfterCameraPermission_whenRequestReturnsTrue_shouldCallAction() throws {
        interactor.isCameraPermitted = nil
        interactor.requestCameraPermissionResult = true
        var actionCallsCount = 0

        testee.performAfterCameraPermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 1)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 1)
        XCTAssertEqual(router.viewControllerCalls.count, 0)
    }

    func test_performAfterCameraPermission_whenRequestReturnsFalse_shouldShowError() throws {
        interactor.isCameraPermitted = nil
        interactor.requestCameraPermissionResult = false
        var actionCallsCount = 0

        testee.performAfterCameraPermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 1)

        wait(for: [router.showExpectation], timeout: 1)
        XCTAssertEqual(router.viewControllerCalls.count, 1)
        try verifyLastShownAlertController(messagePart: "camera")
    }

    // MARK: - Microphone permission

    func test_performAfterMicrophonePermission_whenPermitted_shouldCallAction() {
        interactor.isMicrophonePermitted = true
        var actionCallsCount = 0

        testee.performAfterMicrophonePermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 1)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.lastViewController, nil)
    }

    func test_performAfterMicrophonePermission_whenNotPermitted_shouldShowError() throws {
        interactor.isMicrophonePermitted = false
        var actionCallsCount = 0

        testee.performAfterMicrophonePermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 1)

        try verifyLastShownAlertController(messagePart: "microphone")
    }

    func test_performAfterMicrophonePermission_whenPermissionIsNil_shouldRequestPermission() throws {
        interactor.isMicrophonePermitted = nil
        var actionCallsCount = 0

        testee.performAfterMicrophonePermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 1)
        XCTAssertEqual(router.viewControllerCalls.count, 0)
    }

    func test_performAfterMicrophonePermission_whenRequestReturnsTrue_shouldCallAction() throws {
        interactor.isMicrophonePermitted = nil
        interactor.requestMicrophonePermissionResult = true
        var actionCallsCount = 0

        testee.performAfterMicrophonePermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 1)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 1)
        XCTAssertEqual(router.viewControllerCalls.count, 0)
    }

    func test_performAfterMicrophonePermission_whenRequestReturnsFalse_shouldShowError() throws {
        interactor.isMicrophonePermitted = nil
        interactor.requestMicrophonePermissionResult = false
        var actionCallsCount = 0

        testee.performAfterMicrophonePermission(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 1)

        wait(for: [router.showExpectation], timeout: 1)
        XCTAssertEqual(router.viewControllerCalls.count, 1)
        try verifyLastShownAlertController(messagePart: "microphone")
    }

    // MARK: - Video permissions

    func test_performAfterVideoPermissions_whenBothPermitted_shouldCallAction() {
        interactor.isCameraPermitted = true
        interactor.isMicrophonePermitted = true
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 1)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.lastViewController, nil)
    }

    func test_performAfterVideoPermissions_whenBothNotPermitted_shouldShowError() throws {
        interactor.isCameraPermitted = false
        interactor.isMicrophonePermitted = false
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 1)

        try verifyLastShownAlertController(messagePart: "camera")
    }

    func test_performAfterVideoPermissions_whenCameraNotPermitted_shouldShowError() throws {
        interactor.isCameraPermitted = false
        interactor.isMicrophonePermitted = true
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 1)

        try verifyLastShownAlertController(messagePart: "camera")
    }

    func test_performAfterVideoPermissions_whenMicrophoneNotPermitted_shouldShowError() throws {
        interactor.isCameraPermitted = true
        interactor.isMicrophonePermitted = false
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 1)

        try verifyLastShownAlertController(messagePart: "microphone")
    }

    func test_performAfterVideoPermissions_whenCameraIsPermittedAndMicrophoneIsNil_shouldRequestPermission() throws {
        interactor.isCameraPermitted = true
        interactor.isMicrophonePermitted = nil
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 1)
        XCTAssertEqual(router.viewControllerCalls.count, 0)
    }

    func test_performAfterVideoPermissions_whenCameraIsNotPermittedAndMicrophoneIsNil_shouldShowError() throws {
        interactor.isCameraPermitted = false
        interactor.isMicrophonePermitted = nil
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 0)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 1)

        try verifyLastShownAlertController(messagePart: "camera")
    }

    func test_performAfterVideoPermissions_whenCameraIsNilAndMicrophoneIsPermitted_shouldRequestPermission() throws {
        interactor.isCameraPermitted = nil
        interactor.isMicrophonePermitted = true
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 1)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 0)
    }

    func test_performAfterVideoPermissions_whenCameraIsNilAndMicrophoneIsNotPermitted_shouldRequestPermission() throws {
        interactor.isCameraPermitted = nil
        interactor.isMicrophonePermitted = false
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 1)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 0)
    }

    func test_performAfterVideoPermissions_whenBothAreNil_shouldRequestPermission() throws {
        interactor.isCameraPermitted = nil
        interactor.isMicrophonePermitted = nil
        var actionCallsCount = 0

        testee.performAfterVideoPermissions(from: .init(sourceVC)) { actionCallsCount += 1 }

        XCTAssertEqual(actionCallsCount, 0)
        XCTAssertEqual(interactor.requestCameraPermissionCallsCount, 1)
        XCTAssertEqual(interactor.requestMicrophonePermissionCallsCount, 0)
        XCTAssertEqual(router.viewControllerCalls.count, 0)
    }

    // MARK: - Private helpers

    private func verifyLastShownAlertController(messagePart: String) throws {
        // presentation
        let alertController = try XCTUnwrap(router.viewControllerCalls.last?.0 as? UIAlertController)
        XCTAssertEqual(router.viewControllerCalls.last?.1, sourceVC)
        XCTAssertEqual(router.viewControllerCalls.last?.2.isModal, true)

        // actions
        let firstAction = try XCTUnwrap(alertController.actions.first as? AlertAction)
        let lastAction = try XCTUnwrap(alertController.actions.last as? AlertAction)
        XCTAssertEqual(firstAction.title, "Settings")
        XCTAssertEqual(lastAction.title, "Cancel")
        XCTAssertContainsIgnoringCase(alertController.message, messagePart)

        // open settings
        firstAction.handler?(firstAction)
        XCTAssertEqual(loginDelegate.externalURL?.absoluteString, UIApplication.openSettingsURLString)
    }
}

// MARK: - Mocks

private class AVPermissionInteractorMock: AVPermissionInteractor {

    var isCameraPermitted: Bool?
    var isMicrophonePermitted: Bool?

    // MARK: - requestCameraPermission

    private(set) var requestCameraPermissionCallsCount: Int = 0
    var requestCameraPermissionResult: Bool?

    func requestCameraPermission(_ response: @escaping (Bool) -> Void) {
        requestCameraPermissionCallsCount += 1
        if let result = requestCameraPermissionResult {
            response(result)
        }
    }

    // MARK: - requestMicrophonePermission

    private(set) var requestMicrophonePermissionCallsCount: Int = 0
    var requestMicrophonePermissionResult: Bool?

    func requestMicrophonePermission(_ response: @escaping (Bool) -> Void) {
        requestMicrophonePermissionCallsCount += 1
        if let result = requestMicrophonePermissionResult {
            response(result)
        }
    }
}
