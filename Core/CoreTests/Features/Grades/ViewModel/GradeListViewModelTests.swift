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
        let expectation = expectation(description: "Load grades error expectation")
        let testee = GradeListViewModel(
            interactor: GradeListInteractorErrorMock(expectation: expectation),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(testee.state, .error)
    }

    func testEmptyState() {
        let expectation = expectation(description: "getGrades expectation")
        let testee = GradeListViewModel(
            interactor: GradeListInteractorEmptySectionsMock(expectation: expectation),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(testee.state, .empty(emptySections))
    }

    func test_loadSortPreferences() {
        let expectation = expectation(description: "getGrades expectation")
        let gradeFilterInteractor = GradeFilterInteractorMock()
        _ = GradeListViewModel(
            interactor: GradeListInteractorEmptySectionsMock(expectation: expectation),
            gradeFilterInteractor: gradeFilterInteractor,
            env: PreviewEnvironment.shared
        )
        wait(for: [expectation], timeout: 1)

        XCTAssertTrue(gradeFilterInteractor.selectedSortByIdIsCalled)
    }

    func testRefreshState() async {
        let expectation = expectation(description: "getGrades expectation")
        expectation.assertForOverFulfill = false
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData, expectation: expectation)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )

        XCTAssertEqual(testee.state, .initialLoading)
        await fulfillment(of: [expectation], timeout: 1)

        await testee.refresh()

        XCTAssertEqual(testee.state, .data(gradeListData))
    }

    func test_getSelectedGradingPeriodId() async {
        let expectation = expectation(description: "getGrades expectation")
        expectation.assertForOverFulfill = false
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData, expectation: expectation)
        let gradeFilterInteractor = GradeFilterInteractorMock()
        gradeFilterInteractor.currentGradingId = "1"
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: gradeFilterInteractor,
            env: PreviewEnvironment.shared
        )

        XCTAssertEqual(testee.state, .initialLoading)
        await fulfillment(of: [expectation], timeout: 1)

        await testee.refresh()

        XCTAssertEqual(testee.state, .data(gradeListData))
    }

    func testSelectedGradingPeriod() {
        let expectation = expectation(description: "getGrades expectation")
        let interactor = GradeListInteractorMock(expectation: expectation)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )
        wait(for: [expectation], timeout: 1)

        testee.selectGradingPeriod(id: "999")

        XCTAssertEqual(interactor.ignoreCache, true)
        XCTAssertEqual(interactor.gradingPeriod, "999")
    }

    func testPullToRefresh() async {
        let expectation = expectation(description: "getGrades expectation")
        expectation.assertForOverFulfill = false
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData, expectation: expectation)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )

        await fulfillment(of: [expectation], timeout: 1)
        await testee.refresh()

        XCTAssertEqual(interactor.ignoreCache, true)
        XCTAssertEqual(testee.state, .data(gradeListData))
    }

    func testDidSelectAssignment() {
        let expectation = expectation(description: "getGrades expectation")
        let router = TestRouter()
        let env = environment
        env.router = router
        let testee = GradeListViewModel(
            interactor: GradeListInteractorMock(expectation: expectation),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: env
        )
        wait(for: [expectation], timeout: 1)

        let assignment = Assignment.make()
        testee.selectAssignment(url: assignment.htmlURL, id: assignment.id, controller: WeakViewController())

        XCTAssertEqual(assignment.id, testee.selectedAssignmentId)
        XCTAssertEqual(router.calls[0].0, URLComponents(string: "/courses/1/assignments/1"))
        XCTAssertEqual(router.calls[0].2, RouteOptions.detail)
    }

    func test_navigateToFilter() {
        // Given
        let expectation = expectation(description: "getGrades expectation")
        let viewController = WeakViewController()
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData, expectation: expectation)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )
        wait(for: [expectation], timeout: 1)

        // When
        testee.navigateToFilter(viewController: viewController)
        wait(for: [router.showExpectation], timeout: 1)
        // Then
        XCTAssertTrue(router.presented is CoreHostingController<GradeFilterScreen>)
    }
}

private extension GradeListViewModelTests {
    class GradeListInteractorErrorMock: GradeListInteractor {
        let expectation: XCTestExpectation

        init(expectation: XCTestExpectation) {
            self.expectation = expectation
        }

        func loadBaseData(ignoreCache: Bool) async throws -> Core.GradeListGradingPeriodData {
            defer { expectation.fulfill() }
            throw NSError.instructureError("")
        }

        var courseID: String { "" }
        func getGrades(
            arrangeBy: Core.GradeArrangementOptions,
            baseOnGradedAssignment: Bool,
            gradingPeriodID: String?,
            ignoreCache: Bool
        ) async throws -> Core.GradeListData {
            defer { expectation.fulfill() }
            throw NSError.instructureError("")
        }

        func updateGradingPeriod(id _: String?) {}
        func isWhatIfScoreFlagEnabled() -> Bool { false }
    }

    class GradeListInteractorEmptySectionsMock: GradeListInteractor {
        let expectation: XCTestExpectation

        init(expectation: XCTestExpectation) {
            self.expectation = expectation
        }

        func loadBaseData(ignoreCache: Bool) async throws -> Core.GradeListGradingPeriodData {
            GradeListGradingPeriodData(
                course: .save(.make(), in: singleSharedTestDatabase.viewContext),
                currentlyActiveGradingPeriodID: nil,
                gradingPeriods: []
            )
        }

        var courseID: String { "" }
        func getGrades(
            arrangeBy: Core.GradeArrangementOptions,
            baseOnGradedAssignment: Bool,
            gradingPeriodID: String?,
            ignoreCache: Bool
        ) async throws -> Core.GradeListData {
            expectation.fulfill()
            return emptySections
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
        let expectation: XCTestExpectation

        enum GradeListInteractorMockError: Error {
            case noDataToReturn
        }

        init(dataToReturn: GradeListData? = nil, expectation: XCTestExpectation) {
            self.dataToReturn = dataToReturn
            self.expectation = expectation
        }

        func loadBaseData(ignoreCache: Bool) async throws -> Core.GradeListGradingPeriodData {
            GradeListGradingPeriodData(
                course: .save(.make(), in: singleSharedTestDatabase.viewContext),
                currentlyActiveGradingPeriodID: nil,
                gradingPeriods: []
            )
        }

        func getGrades(
            arrangeBy: Core.GradeArrangementOptions,
            baseOnGradedAssignment: Bool,
            gradingPeriodID: String?,
            ignoreCache: Bool
        ) async throws -> Core.GradeListData {
            defer { expectation.fulfill() }

            self.ignoreCache = ignoreCache
            self.arrangeBy = arrangeBy
            gradingPeriod = gradingPeriodID

            if let dataToReturn {
                return dataToReturn
            } else {
                throw GradeListInteractorMockError.noDataToReturn
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
        AssignmentListSection(id: "1", title: "First group", rows: [.gradeListRow(.init(assignment: .make(), userId: ""))]),
        AssignmentListSection(id: "2", title: "Second group", rows: [.gradeListRow(.init(assignment: .make(), userId: ""))]),
        AssignmentListSection(id: "3", title: "Third group", rows: [.gradeListRow(.init(assignment: .make(), userId: ""))])
    ],
    isGradingPeriodHidden: false,
    gradingPeriods: [.make()],
    currentGradingPeriod: nil,
    totalGradeText: nil
)
