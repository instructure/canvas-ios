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

final class LearningLibraryItemNavigatingTests: HorizonTestCase {

    func testNavigateToCourseWithEnrollmentId() {
        let testNavigator = TestNavigator(router: router)
        let courseCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Swift Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: false,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: true,
            isInProgress: true,
            courseEnrollmentId: "enrollment-456"
        )

        testNavigator.navigateToLearningLibraryItem(courseCard, from: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(presentedVC)
    }

    func testNavigateToCourseWithoutEnrollmentIdDoesNotNavigate() {
        let testNavigator = TestNavigator(router: router)
        let courseCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Swift Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: false,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false,
            isInProgress: false,
            courseEnrollmentId: nil
        )

        testNavigator.navigateToLearningLibraryItem(courseCard, from: WeakViewController(UIViewController()))

        XCTAssertFalse(router.showExpectation.isInverted)
    }

    func test_navigateToItemSequence_callsRouterWithCorrectParameters() {
        let testNavigator = TestNavigator(router: router)
        let model = LearningLibraryCardModel(
            id: "item-2",
            courseID: "12",
            name: "Career Program",
            imageURL: nil,
            itemType: .assessment,
            estimatedTime: nil,
            isRecommended: false,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: nil,
            isEnrolled: false,
            moduleItemID: "100",
            canvasUrl: URL(string: "https://example.com")
        )

        let url = URL(string: "https://example.com/courses/12/modules/items/100")!
        testNavigator.navigateToLearningLibraryItem(model, from: WeakViewController(UIViewController()))

        XCTAssertEqual(router.calls.count, 1)
        XCTAssertEqual(router.calls[0].0?.url, url)
    }

    func testNavigateToProgramShowsProgramDetails() {
        let testNavigator = TestNavigator(router: router)
        let programCard = LearningLibraryCardModel(
            id: "item-2",
            courseID: "program-789",
            name: "Career Program",
            imageURL: nil,
            itemType: .program,
            estimatedTime: nil,
            isRecommended: false,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: nil,
            isEnrolled: false
        )

        testNavigator.navigateToLearningLibraryItem(programCard, from: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.ProgramDetailsView>
        XCTAssertNotNil(presentedVC)
    }

    func testNavigateToPageDoesNotNavigate() {
        let testNavigator = TestNavigator(router: router)
        let pageCard = LearningLibraryCardModel(
            id: "item-3",
            courseID: "page-123",
            name: "Resource Page",
            imageURL: nil,
            itemType: .page,
            estimatedTime: nil,
            isRecommended: false,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: nil,
            isEnrolled: false
        )

        testNavigator.navigateToLearningLibraryItem(pageCard, from: WeakViewController(UIViewController()))

        XCTAssertFalse(router.showExpectation.isInverted)
    }

    func testNavigateToAssignmentDoesNotNavigate() {
        let testNavigator = TestNavigator(router: router)
        let assignmentCard = LearningLibraryCardModel(
            id: "item-4",
            courseID: "assignment-123",
            name: "Assignment",
            imageURL: nil,
            itemType: .assignment,
            estimatedTime: nil,
            isRecommended: false,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: nil,
            isEnrolled: false
        )

        testNavigator.navigateToLearningLibraryItem(assignmentCard, from: WeakViewController(UIViewController()))

        XCTAssertFalse(router.showExpectation.isInverted)
    }

    func testNavigateToFileDoesNotNavigate() {
        let testNavigator = TestNavigator(router: router)
        let fileCard = LearningLibraryCardModel(
            id: "item-5",
            courseID: "file-123",
            name: "PDF File",
            imageURL: nil,
            itemType: .file,
            estimatedTime: nil,
            isRecommended: false,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: nil,
            isEnrolled: false
        )

        testNavigator.navigateToLearningLibraryItem(fileCard, from: WeakViewController(UIViewController()))

        XCTAssertFalse(router.showExpectation.isInverted)
    }
}

// MARK: - Test Navigator

private class TestNavigator: LearningLibraryItemNavigating {
    let router: Router

    init(router: Router) {
        self.router = router
    }
}
