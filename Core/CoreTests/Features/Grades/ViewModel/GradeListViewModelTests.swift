//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Foundation
import TestsFoundation
import XCTest

class GradeListViewModelTests: CoreTestCase {
    func testErrorState() {
        let testee = GradeListViewModel(
            interactor: GradeListInteractorErrorMock(),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared,
            scheduler: .immediate
        )
        XCTAssertEqual(testee.state, .error)
    }

    func testEmptyState() {
        let testee = GradeListViewModel(
            interactor: GradeListInteractorEmptySectionsMock(),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared,
            scheduler: .immediate
        )
        XCTAssertEqual(testee.state, .empty(emptySections))
    }

    func test_loadSortPreferences() {
        let gradeFilterInteractor = GradeFilterInteractorMock()
        _ = GradeListViewModel(
            interactor: GradeListInteractorEmptySectionsMock(),
            gradeFilterInteractor: gradeFilterInteractor,
            env: PreviewEnvironment.shared,
            scheduler: .immediate
        )
        XCTAssertTrue(gradeFilterInteractor.selectedSortByIdIsCalled)
    }

    func testRefreshState() {
        var states: [GradeListViewModel.ViewState] = []
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let expectation = expectation(description: "Publisher sends value.")
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared,
            scheduler: .immediate
        )

        let subscription = testee.$state
            .sink { _ in

            } receiveValue: { state in
                states.append(state)
                if states.count == 2 {
                    expectation.fulfill()
                }
            }

        testee.pullToRefreshDidTrigger.accept((nil))
        XCTAssertEqual(states[1], .initialLoading)
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func test_getSelectedGradingPeriodId() {
        var states: [GradeListViewModel.ViewState] = []
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let expectation = expectation(description: "Publisher sends value.")
        let gradeFilterInteractor = GradeFilterInteractorMock()
        gradeFilterInteractor.currentGradingId = "1"
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: gradeFilterInteractor,
            env: PreviewEnvironment.shared,
            scheduler: .immediate
        )

        let subscription = testee.$state
            .sink { _ in

            } receiveValue: { state in
                states.append(state)
                if states.count == 2 {
                    expectation.fulfill()
                }
            }

        testee.pullToRefreshDidTrigger.accept((nil))
        XCTAssertEqual(states[1], .initialLoading)
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testSelectedGradingPeriod() {
        let interactor = GradeListInteractorMock()
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared,
            scheduler: .immediate
        )
        testee.didSelectGradingPeriod.accept("999")

        XCTAssertEqual(interactor.ignoreCache, true)
        XCTAssertEqual(interactor.gradingPeriod, "999")
    }

    func testPullToRefresh() {
        var completionCalled = false
        let completion: () -> Void = {
            completionCalled = true
        }
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared,
            scheduler: .immediate
        )
        testee.pullToRefreshDidTrigger.accept(completion)
        XCTAssertEqual(completionCalled, true)
        XCTAssertEqual(interactor.ignoreCache, true)
        XCTAssertEqual(testee.state, .data(gradeListData))
    }

    func testDidSelectAssignment() {
        let router = TestRouter()
        let env = environment
        env.router = router
        let testee = GradeListViewModel(
            interactor: GradeListInteractorMock(),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: env,
            scheduler: .immediate
        )
        testee.didSelectAssignment.accept((WeakViewController(), Assignment.make()))
        XCTAssertEqual(router.calls[0].0, URLComponents(string: "/courses//assignments/1"))
        XCTAssertEqual(router.calls[0].2, RouteOptions.detail)
    }

    func test_navigateToFilter() {
        // Given
        let viewController = WeakViewController()
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared,
            scheduler: .immediate
        )

        // When
        testee.navigateToFilter(viewController: viewController)
        wait(for: [router.showExpectation], timeout: 1)
        // Then
        XCTAssertTrue(router.presented is CoreHostingController<GradeFilterView>)
    }
}

private extension GradeListViewModelTests {
    class GradeListInteractorErrorMock: GradeListInteractor {
        func loadBaseData(ignoreCache: Bool) -> AnyPublisher<GradeListGradingPeriodData, any Error> {
            Fail(error: NSError.instructureError("")).eraseToAnyPublisher()
        }

        var courseID: String { "" }
        func getGrades(
            arrangeBy: GradeArrangementOptions,
            baseOnGradedAssignment: Bool,
            gradingPeriodID: String?,
            ignoreCache: Bool
        ) -> AnyPublisher<Core.GradeListData, Error> {
            Fail(error: NSError.instructureError("")).eraseToAnyPublisher()
        }

        func updateGradingPeriod(id _: String?) {}
        func isWhatIfScoreFlagEnabled() -> Bool { false }
    }

    class GradeListInteractorEmptySectionsMock: GradeListInteractor {
        func loadBaseData(ignoreCache: Bool) -> AnyPublisher<GradeListGradingPeriodData, any Error> {
            let result = GradeListGradingPeriodData(
                course: .save(.make(), in: singleSharedTestDatabase.viewContext),
                currentlyActiveGradingPeriodID: nil,
                gradingPeriods: []
            )
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        var courseID: String { "" }
        func getGrades(
            arrangeBy: GradeArrangementOptions,
            baseOnGradedAssignment: Bool,
            gradingPeriodID: String?,
            ignoreCache: Bool
        ) -> AnyPublisher<Core.GradeListData, Error> {
            Just(emptySections)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        func updateGradingPeriod(id _: String?) {}
        func isWhatIfScoreFlagEnabled() -> Bool { false }
    }

    class GradeListInteractorMock: GradeListInteractor {
        var ignoreCache: Bool?
        var gradingPeriod: String?
        var arrangeBy: GradeArrangementOptions?
        let dataToReturn: GradeListData?
        var courseID: String { "" }

        init(dataToReturn: GradeListData? = nil) {
            self.dataToReturn = dataToReturn
        }

        func loadBaseData(ignoreCache: Bool) -> AnyPublisher<Core.GradeListGradingPeriodData, any Error> {
            let result = GradeListGradingPeriodData(
                course: .save(.make(), in: singleSharedTestDatabase.viewContext),
                currentlyActiveGradingPeriodID: nil,
                gradingPeriods: []
            )
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        func getGrades(
            arrangeBy: GradeArrangementOptions,
            baseOnGradedAssignment: Bool,
            gradingPeriodID: String?,
            ignoreCache: Bool
        ) -> AnyPublisher<Core.GradeListData, Error> {
            self.ignoreCache = ignoreCache
            self.arrangeBy = arrangeBy
            gradingPeriod = gradingPeriodID

            if let dataToReturn {
                return Just(dataToReturn)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                return Empty()
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        func isWhatIfScoreFlagEnabled() -> Bool { false }
    }
}

private let emptySections = GradeListData(
    id: "",
    userID: "",
    courseName: "",
    courseColor: nil,
    assignmentSections: [],
    isGradingPeriodHidden: false,
    gradingPeriods: [],
    currentGradingPeriod: nil,
    totalGradeText: nil
)

private let gradeListData = GradeListData(
    id: "",
    userID: "",
    courseName: "",
    courseColor: nil,
    assignmentSections: [
        GradeListData.AssignmentSections(id: "1", title: "First group", assignments: [.make()]),
        GradeListData.AssignmentSections(id: "2", title: "Second group", assignments: [.make()]),
        GradeListData.AssignmentSections(id: "3", title: "Third group", assignments: [.make()])
    ],
    isGradingPeriodHidden: false,
    gradingPeriods: [.make()],
    currentGradingPeriod: nil,
    totalGradeText: nil
)
