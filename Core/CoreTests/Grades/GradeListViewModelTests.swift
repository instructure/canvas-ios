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

class GradeListViewModelTests: CoreTestCase {
    func testErrorState() {
        let testee = GradeListViewModel(
            interactor: GradeListInteractorErrorMock(),
            router: PreviewEnvironment.shared.router,
            scheduler: .immediate
        )
        XCTAssertEqual(testee.state, .error)
    }

    func testEmptyState() {
        let testee = GradeListViewModel(
            interactor: GradeListInteractorEmptySectionsMock(),
            router: PreviewEnvironment.shared.router,
            scheduler: .immediate
        )
        XCTAssertEqual(testee.state, .empty(emptySections))
    }

    func testRefreshState() {
        var states: [GradeListViewModel.ViewState] = []
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let expectation = expectation(description: "Publisher sends value.")
        let testee = GradeListViewModel(
            interactor: interactor,
            router: PreviewEnvironment.shared.router,
            scheduler: .immediate
        )

        let subscription = testee.$state
            .sink { _ in

            } receiveValue: { state in
                states.append(state)
                if states.count == 3 {
                    expectation.fulfill()
                }
            }

        testee.pullToRefreshDidTrigger.accept((nil))
        XCTAssertEqual(states[1], .refreshing(gradeListData))
        XCTAssertEqual(states[2], .data(gradeListData))
        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testSelectedGradingPeriod() {
        let interactor = GradeListInteractorMock()
        let testee = GradeListViewModel(
            interactor: interactor,
            router: PreviewEnvironment.shared.router,
            scheduler: .immediate
        )
        testee.selectedGradingPeriod.accept(
            .save(
                .make(id: "999"),
                courseID: "1",
                in: PreviewEnvironment.shared.database.viewContext
            )
        )
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
            router: PreviewEnvironment.shared.router,
            scheduler: .immediate
        )
        testee.pullToRefreshDidTrigger.accept(completion)
        XCTAssertEqual(completionCalled, true)
        XCTAssertEqual(interactor.ignoreCache, true)
        XCTAssertEqual(testee.state, .data(gradeListData))
    }

    func testDidSelectAssignment() {
        let router = TestRouter()
        let testee = GradeListViewModel(
            interactor: GradeListInteractorMock(),
            router: router,
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
            router: PreviewEnvironment.shared.router,
            scheduler: .immediate
        )

        // When
        testee.navigateToFilter(viewController: viewController)
        wait(for: [router.showExpectation], timeout: 0.1)
        // Then
        XCTAssertTrue(router.presented is CoreHostingController<GradeFilterView>)
    }
}

private extension GradeListViewModelTests {
    class GradeListInteractorErrorMock: GradeListInteractor {
        var courseID: String { "" }
        func getGrades(
            arrangeBy _: Core.GradeArrangementOptions,
            baseOnGradedAssignment _: Bool,
            ignoreCache _: Bool
        ) -> AnyPublisher<Core.GradeListData, Error> {
            Fail(error: NSError.instructureError("")).eraseToAnyPublisher()
        }

        func updateGradingPeriod(id _: String?) {}
        func isWhatIfScoreFlagEnabled() -> Bool { false }
    }

    class GradeListInteractorEmptySectionsMock: GradeListInteractor {
        var courseID: String { "" }
        func getGrades(
            arrangeBy _: Core.GradeArrangementOptions,
            baseOnGradedAssignment _: Bool,
            ignoreCache _: Bool
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

        func getGrades(
            arrangeBy: Core.GradeArrangementOptions,
            baseOnGradedAssignment _: Bool,
            ignoreCache: Bool
        ) -> AnyPublisher<Core.GradeListData, Error> {
            self.ignoreCache = ignoreCache
            self.arrangeBy = arrangeBy

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

        func updateGradingPeriod(id: String?) {
            gradingPeriod = id
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
    gradingPeriods: [],
    currentGradingPeriod: nil,
    totalGradeText: nil
)
