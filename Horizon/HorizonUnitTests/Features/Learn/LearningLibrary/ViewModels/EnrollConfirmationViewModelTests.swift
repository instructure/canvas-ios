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

@testable import Horizon
@testable import Core
import XCTest
import Combine
import CombineSchedulers

final class EnrollConfirmationViewModelTests: HorizonTestCase {

    // MARK: - Initial State Tests

    func testInitialStateShowsLoader() {
        let mockCard = createMockCard()
        let interactor = LearningLibraryInteractorMock()
        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in }
        )

        XCTAssertTrue(testee.isLoaderVisible)
        XCTAssertFalse(testee.isEnrollLoaderVisible)
        XCTAssertFalse(testee.isErrorVisible)
    }

    func testInitialOverviewIsNil() {
        let mockCard = createMockCard()
        let interactor = LearningLibraryInteractorMock()
        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in }
        )

        XCTAssertNil(testee.overView)
    }

    // MARK: - Enroll Tests

    func testEnrollSuccessCallsOnTap() {
        let mockCard = createMockCard()
        let enrolledCard = createMockCard(isEnrolled: true, enrollmentId: "enrollment-999")
        let interactor = LearningLibraryInteractorMock(enrollResponse: enrolledCard)
        let expectation = expectation(description: "onTap called")
        var receivedCard: LearningLibraryCardModel?

        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { card in
                receivedCard = card
                expectation.fulfill()
            }
        )

        testee.enroll(viewController: WeakViewController(UIViewController()))

        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(receivedCard)
        XCTAssertEqual(receivedCard?.id, enrolledCard.id)
        XCTAssertTrue(receivedCard?.isEnrolled ?? false)
        XCTAssertFalse(testee.isEnrollLoaderVisible)
    }

    func testEnrollShowsLoadingState() {
        let mockCard = createMockCard()
        let enrolledCard = createMockCard(isEnrolled: true)
        let interactor = LearningLibraryInteractorMock(enrollResponse: enrolledCard)

        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in }
        )

        testee.enroll(viewController: WeakViewController(UIViewController()))

        XCTAssertFalse(testee.isEnrollLoaderVisible)
    }

    func testEnrollDismissesViewControllerOnSuccess() {
        let mockCard = createMockCard()
        let enrolledCard = createMockCard(isEnrolled: true)
        let interactor = LearningLibraryInteractorMock(enrollResponse: enrolledCard)

        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in }
        )

        testee.enroll(viewController: WeakViewController(UIViewController()))

        wait(for: [router.dismissExpectation], timeout: 0.1)
    }

    func testEnrollErrorShowsError() {
        let mockCard = createMockCard()
        let interactor = LearningLibraryInteractorMock(hasError: true)

        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in }
        )

        testee.enroll(viewController: WeakViewController(UIViewController()))

        XCTAssertTrue(testee.isErrorVisible)
        XCTAssertFalse(testee.errorMessage.isEmpty)
        XCTAssertFalse(testee.isEnrollLoaderVisible)
    }

    func testEnrollErrorDoesNotDismiss() {
        let mockCard = createMockCard()
        let interactor = LearningLibraryInteractorMock(hasError: true)

        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in }
        )

        testee.enroll(viewController: WeakViewController(UIViewController()))

        XCTAssertTrue(testee.isErrorVisible)
    }

    func testEnrollErrorDoesNotCallOnTap() {
        let mockCard = createMockCard()
        let interactor = LearningLibraryInteractorMock(hasError: true)
        var onTapCalled = false

        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in onTapCalled = true }
        )

        testee.enroll(viewController: WeakViewController(UIViewController()))

        XCTAssertFalse(onTapCalled)
    }

    // MARK: - Dismiss Tests

    func testDismissCallsRouter() {
        let mockCard = createMockCard()
        let interactor = LearningLibraryInteractorMock()

        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in }
        )

        testee.dismiss(viewController: WeakViewController(UIViewController()))

        wait(for: [router.dismissExpectation], timeout: 0.1)
    }

    func testDismissCallsCompletion() {
        let mockCard = createMockCard()
        let interactor = LearningLibraryInteractorMock()
        let expectation = expectation(description: "Completion called")

        let testee = EnrollConfirmationViewModel(
            model: mockCard,
            router: router,
            interactor: interactor,
            scheduler: .immediate,
            onTap: { _ in }
        )

        testee.dismiss(viewController: WeakViewController(UIViewController())) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - Helper Methods

    private func createMockCard(
        isBookmarked: Bool = false,
        isEnrolled: Bool = false,
        enrollmentId: String? = nil
    ) -> LearningLibraryCardModel {
        LearningLibraryCardModel(
            id: "item-1",
            itemId: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: false,
            isCompleted: false,
            isBookmarked: isBookmarked,
            numberOfUnits: 5,
            isEnrolled: isEnrolled,
            isInProgress: false,
            courseEnrollmentId: enrollmentId
        )
    }
}
