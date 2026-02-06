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
@testable import Core
@testable import Student
import XCTest

final class CourseInvitationCardViewModelTests: XCTestCase {

    private var testee: CourseInvitationCardViewModel!
    private var mockInteractor: CoursesInteractorMock!
    private var mockSnackBar: MockSnackBarViewModel!
    private var dismissCalled: Bool!
    private var dismissedEnrollmentId: String?

    override func setUp() {
        super.setUp()
        mockInteractor = CoursesInteractorMock()
        mockSnackBar = MockSnackBarViewModel()
        dismissCalled = false
        dismissedEnrollmentId = nil
    }

    override func tearDown() {
        testee = nil
        mockInteractor = nil
        mockSnackBar = nil
        dismissCalled = nil
        dismissedEnrollmentId = nil
        super.tearDown()
    }

    private func waitForAsyncOperation() {
        let expectation = expectation(description: "async operation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }

    // MARK: - Initialization Tests

    func testInit_setsInitialProperties() {
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        XCTAssertEqual(testee.id, "enrollment1")
        XCTAssertFalse(testee.isAccepting)
        XCTAssertFalse(testee.isDeclining)
        XCTAssertFalse(testee.isProcessing)
    }

    func testInit_displayNameWithoutSection() {
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        XCTAssertEqual(testee.displayName, "Biology 101")
    }

    func testInit_displayNameWithDifferentSection() {
        testee = .make(sectionName: "Section A", interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        XCTAssertEqual(testee.displayName, "Biology 101, Section A")
    }

    func testInit_displayNameWithMatchingSection() {
        testee = .make(sectionName: "Biology 101", interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        XCTAssertEqual(testee.displayName, "Biology 101")
    }

    // MARK: - Accept Flow Tests

    func testAccept_setsIsAcceptingDuringOperation() {
        mockInteractor.acceptBehavior = .success
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.accept()
        XCTAssertTrue(testee.isAccepting)
    }

    func testAccept_showsSuccessSnackbar() {
        mockInteractor.acceptBehavior = .success
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.accept()
        waitForAsyncOperation()

        XCTAssertEqual(mockSnackBar.shownSnacks.last, "Accepted invitation to Biology 101")
    }

    func testAccept_callsOnDismissCallback() {
        mockInteractor.acceptBehavior = .success
        testee = .make(
            interactor: mockInteractor,
            snackBarViewModel: mockSnackBar,
            onDismiss: { [weak self] enrollmentId in
                self?.dismissCalled = true
                self?.dismissedEnrollmentId = enrollmentId
            }
        )

        testee.accept()
        waitForAsyncOperation()

        XCTAssertTrue(dismissCalled)
        XCTAssertEqual(dismissedEnrollmentId, "enrollment1")
    }

    func testAccept_resetsIsAcceptingAfterSuccess() {
        mockInteractor.acceptBehavior = .success
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.accept()
        XCTAssertTrue(testee.isAccepting)

        waitForAsyncOperation()
        XCTAssertFalse(testee.isAccepting)
    }

    func testAccept_showsErrorAlertOnFailure() {
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockInteractor.acceptBehavior = .failure(testError)
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.accept()
        waitForAsyncOperation()

        XCTAssertTrue(testee.isShowingErrorAlert)
        XCTAssertEqual(testee.errorAlert.message, "Failed to accept invitation. Please try again.")
    }

    func testAccept_resetsIsAcceptingAfterFailure() {
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockInteractor.acceptBehavior = .failure(testError)
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.accept()
        XCTAssertTrue(testee.isAccepting)

        waitForAsyncOperation()
        XCTAssertFalse(testee.isAccepting)
    }

    func testAccept_ignoresWhenIsProcessing() {
        mockInteractor.acceptBehavior = .success
        testee = .make(
            interactor: mockInteractor,
            snackBarViewModel: mockSnackBar,
            onDismiss: { [weak self] _ in
                self?.dismissCalled = true
            }
        )

        testee.accept()
        XCTAssertTrue(testee.isAccepting)

        testee.accept()

        waitForAsyncOperation()
        XCTAssertTrue(dismissCalled)
    }

    // MARK: - Decline Flow Tests

    func testDecline_setsIsDecliningDuringOperation() {
        mockInteractor.declineBehavior = .success
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.decline()
        XCTAssertTrue(testee.isDeclining)
    }

    func testDecline_showsSuccessSnackbar() {
        mockInteractor.declineBehavior = .success
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.decline()
        waitForAsyncOperation()

        XCTAssertEqual(mockSnackBar.shownSnacks.last, "Declined invitation to Biology 101")
    }

    func testDecline_callsOnDismissCallback() {
        mockInteractor.declineBehavior = .success
        testee = .make(
            interactor: mockInteractor,
            snackBarViewModel: mockSnackBar,
            onDismiss: { [weak self] enrollmentId in
                self?.dismissCalled = true
                self?.dismissedEnrollmentId = enrollmentId
            }
        )

        testee.decline()
        waitForAsyncOperation()

        XCTAssertTrue(dismissCalled)
        XCTAssertEqual(dismissedEnrollmentId, "enrollment1")
    }

    func testDecline_resetsIsDecliningAfterSuccess() {
        mockInteractor.declineBehavior = .success
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.decline()
        XCTAssertTrue(testee.isDeclining)

        waitForAsyncOperation()
        XCTAssertFalse(testee.isDeclining)
    }

    func testDecline_showsErrorAlertOnFailure() {
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockInteractor.declineBehavior = .failure(testError)
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.decline()
        waitForAsyncOperation()

        XCTAssertTrue(testee.isShowingErrorAlert)
        XCTAssertEqual(testee.errorAlert.message, "Failed to decline invitation. Please try again.")
    }

    func testDecline_resetsIsDecliningAfterFailure() {
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockInteractor.declineBehavior = .failure(testError)
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.decline()
        XCTAssertTrue(testee.isDeclining)

        waitForAsyncOperation()
        XCTAssertFalse(testee.isDeclining)
    }

    func testDecline_ignoresWhenIsProcessing() {
        mockInteractor.declineBehavior = .success
        testee = .make(
            interactor: mockInteractor,
            snackBarViewModel: mockSnackBar,
            onDismiss: { [weak self] _ in
                self?.dismissCalled = true
            }
        )

        testee.decline()
        XCTAssertTrue(testee.isDeclining)

        testee.decline()

        waitForAsyncOperation()
        XCTAssertTrue(dismissCalled)
    }

    // MARK: - Processing State Tests

    func testIsProcessing_trueWhenAccepting() {
        mockInteractor.acceptBehavior = .success
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.accept()
        XCTAssertTrue(testee.isProcessing)
    }

    func testIsProcessing_trueWhenDeclining() {
        mockInteractor.declineBehavior = .success
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        testee.decline()
        XCTAssertTrue(testee.isProcessing)
    }

    func testIsProcessing_falseWhenIdle() {
        testee = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        XCTAssertFalse(testee.isProcessing)
    }

    // MARK: - Equatable Tests

    func testEquatable_sameValuesAreEqual() {
        let vm1: CourseInvitationCardViewModel = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)
        let vm2: CourseInvitationCardViewModel = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        XCTAssertEqual(vm1, vm2)
    }

    func testEquatable_differentIdsNotEqual() {
        let vm1: CourseInvitationCardViewModel = .make(id: "enrollment1", interactor: mockInteractor, snackBarViewModel: mockSnackBar)
        let vm2: CourseInvitationCardViewModel = .make(id: "enrollment2", interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        XCTAssertNotEqual(vm1, vm2)
    }

    func testEquatable_differentDisplayNamesNotEqual() {
        let vm1: CourseInvitationCardViewModel = .make(courseName: "Biology 101", interactor: mockInteractor, snackBarViewModel: mockSnackBar)
        let vm2: CourseInvitationCardViewModel = .make(courseName: "Chemistry 201", interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        XCTAssertNotEqual(vm1, vm2)
    }

    func testEquatable_differentLoadingStatesNotEqual() {
        mockInteractor.acceptBehavior = .success
        let vm1: CourseInvitationCardViewModel = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)
        let vm2: CourseInvitationCardViewModel = .make(interactor: mockInteractor, snackBarViewModel: mockSnackBar)

        vm1.accept()

        XCTAssertNotEqual(vm1, vm2)
    }
}

private class MockSnackBarViewModel: SnackBarViewModel {
    var shownSnacks: [String] = []

    override func showSnack(_ snack: String, swallowDuplicatedSnacks: Bool = false) {
        shownSnacks.append(snack)
    }
}

private extension CourseInvitationCardViewModel {
    static func make(
        id: String = "enrollment1",
        courseId: String = "course1",
        courseName: String = "Biology 101",
        sectionName: String? = nil,
        interactor: CoursesInteractor,
        snackBarViewModel: SnackBarViewModel,
        onDismiss: @escaping (String) -> Void = { _ in }
    ) -> CourseInvitationCardViewModel {
        CourseInvitationCardViewModel(
            id: id,
            courseId: courseId,
            courseName: courseName,
            sectionName: sectionName,
            interactor: interactor,
            snackBarViewModel: snackBarViewModel,
            onDismiss: onDismiss
        )
    }
}
