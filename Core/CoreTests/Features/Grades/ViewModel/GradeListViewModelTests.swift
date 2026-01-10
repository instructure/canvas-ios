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
    func testErrorState() async {
        let testee = GradeListViewModel(
            interactor: GradeListInteractorErrorMock(),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )
        await testee.task?.value

        XCTAssertEqual(testee.state, .error)
    }

    func testEmptyState() async {
        let testee = GradeListViewModel(
            interactor: GradeListInteractorEmptySectionsMock(),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )
        await testee.task?.value

        XCTAssertEqual(testee.state, .empty(emptySections))
    }

    func test_loadSortPreferences() {
        let gradeFilterInteractor = GradeFilterInteractorMock()
        _ = GradeListViewModel(
            interactor: GradeListInteractorEmptySectionsMock(),
            gradeFilterInteractor: gradeFilterInteractor,
            env: PreviewEnvironment.shared
        )

        XCTAssertTrue(gradeFilterInteractor.selectedSortByIdIsCalled)
    }

    func testRefreshState() async {
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )

        XCTAssertEqual(testee.state, .initialLoading)
        await testee.task?.value

        await testee.refresh()

        XCTAssertEqual(testee.state, .data(gradeListData))
    }

    func test_getSelectedGradingPeriodId() async {
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let gradeFilterInteractor = GradeFilterInteractorMock()
        gradeFilterInteractor.currentGradingId = "1"
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: gradeFilterInteractor,
            env: PreviewEnvironment.shared
        )

        XCTAssertEqual(testee.state, .initialLoading)
        await testee.task?.value

        await testee.refresh()

        XCTAssertEqual(testee.state, .data(gradeListData))
    }

    func testSelectedGradingPeriod() async {
        let interactor = GradeListInteractorMock()
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )

        await testee.task?.value

        testee.selectGradingPeriod(id: "999")

        await testee.task?.value

        XCTAssertEqual(interactor.ignoreCache, true)
        XCTAssertEqual(interactor.gradingPeriod, "999")
    }

    func testPullToRefresh() async {
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )

        await testee.task?.value
        await testee.refresh()

        XCTAssertEqual(interactor.ignoreCache, true)
        XCTAssertEqual(testee.state, .data(gradeListData))
    }

    func testDidSelectAssignment() async {
        let router = TestRouter()
        let env = environment
        env.router = router
        let testee = GradeListViewModel(
            interactor: GradeListInteractorMock(),
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: env
        )
        await testee.task?.value

        let assignment = Assignment.make()
        testee.selectAssignment(url: assignment.htmlURL, id: assignment.id, controller: WeakViewController())

        XCTAssertEqual(assignment.id, testee.selectedAssignmentId)
        XCTAssertEqual(router.calls[0].0, URLComponents(string: "/courses/1/assignments/1"))
        XCTAssertEqual(router.calls[0].2, RouteOptions.detail)
    }

    func test_navigateToFilter() async {
        // Given
        let viewController = WeakViewController()
        let interactor = GradeListInteractorMock(dataToReturn: gradeListData)
        let testee = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: GradeFilterInteractorMock(),
            env: PreviewEnvironment.shared
        )
        await testee.task?.value

        // When
        testee.navigateToFilter(viewController: viewController)
        await fulfillment(of: [router.showExpectation], timeout: 1)
        // Then
        XCTAssertTrue(router.presented is CoreHostingController<GradeFilterScreen>)
    }
}

private extension GradeListViewModelTests {
    class GradeListInteractorErrorMock: GradeListInteractor {
        func loadBaseData(ignoreCache: Bool) async throws -> Core.GradeListGradingPeriodData {
            throw NSError.instructureError("")
        }

        var courseID: String { "" }
        func getGrades(
            arrangeBy: Core.GradeArrangementOptions,
            baseOnGradedAssignment: Bool,
            gradingPeriodID: String?,
            ignoreCache: Bool
        ) async throws -> Core.GradeListData {
            throw NSError.instructureError("")
        }

        func updateGradingPeriod(id _: String?) {}
        func isWhatIfScoreFlagEnabled() -> Bool { false }
    }

    class GradeListInteractorEmptySectionsMock: GradeListInteractor {
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

        init(dataToReturn: GradeListData? = nil) {
            self.dataToReturn = dataToReturn
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
            self.ignoreCache = ignoreCache
            self.arrangeBy = arrangeBy
            gradingPeriod = gradingPeriodID

            return if let dataToReturn {
                dataToReturn
            } else {
                .init()
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
