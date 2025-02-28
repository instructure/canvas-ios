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

import XCTest
import Combine
import CombineExt
@testable import Core
import Foundation
import TestsFoundation

final class GradeFilterViewModelTests: CoreTestCase {

    // MARK: - Properties
    private var testee: GradeFilterViewModel!
    private var subscriptions = Set<AnyCancellable>()
    private var gradeFilterInteractor: GradeFilterInteractorMock!

    override func setUp() {
        super.setUp()
        gradeFilterInteractor = GradeFilterInteractorMock()
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            sortByOptions: GradeArrangementOptions.allCases
        )
        testee = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
    }

    override func tearDownWithError() throws {
        testee = nil
        gradeFilterInteractor = nil
    }

    func test_mapGradingPeriod_hasFiveItemsAndAddAllItem() {
        // Given
        let listGradingPeriods = getListGradingPeriods()
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            gradingPeriods: listGradingPeriods,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        environment.userDefaults?.selectedGradingPeriodIdsByCourseIDs = nil
        let testee = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        // Then
        XCTAssertEqual(testee.gradingPeriodOptions.all.count, 5)
        XCTAssertEqual(testee.gradingPeriodOptions.all.first?.title.contains("All"), true)
        XCTAssertEqual(testee.gradingPeriodOptions.all.dropFirst().map(\.id), listGradingPeriods.map(\.id))
        XCTAssertEqual(testee.gradingPeriodOptions.selected.value?.title.contains("All"), true)
        XCTAssertEqual(testee.isShowGradingPeriodsView, true)
    }

    func test_mapGradingPeriod_hasSelectedGradingPeriods() {
        // Given
        let listGradingPeriods = getListGradingPeriods()
        gradeFilterInteractor.currentGradingId = "4"
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            gradingPeriods: listGradingPeriods,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let testee = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        // Then
        XCTAssertEqual(testee.gradingPeriodOptions.all.count, 5)
        XCTAssertEqual(testee.isShowGradingPeriodsView, true)
        XCTAssertEqual(testee.gradingPeriodOptions.selected.value?.id, "4")
    }

    func test_mapGradingPeriod_notHasGradingPeriods_hideGradingPeriodSection() {
        // Given
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: false,
            gradingPeriods: nil,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let testee = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        // Then
        XCTAssertEqual(testee.gradingPeriodOptions.all, [])
        XCTAssertEqual(testee.isShowGradingPeriodsView, false)
    }

    func test_mapSortByOptions() {
        // Given
        let sortByOptions = GradeArrangementOptions.allCases
        let selectedSortBy = GradeArrangementOptions.dueDate
        gradeFilterInteractor.currentSortById = selectedSortBy.rawValue
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: false,
            gradingPeriods: nil,
            sortByOptions: sortByOptions
        )
        // Then
        let testee = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        XCTAssertEqual(testee.sortModeOptions.all.map(\.id), sortByOptions.map(\.rawValue))
        XCTAssertEqual(testee.sortModeOptions.selected.value?.id, selectedSortBy.rawValue)
    }

    func test_bindSaveButtonStates_statesNotChanged_saveButtonIsDisabled() {
        // Given
        let listGradingPeriods = getListGradingPeriods()
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            gradingPeriods: listGradingPeriods,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let testee = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        // Then
        XCTAssertEqual(testee.saveButtonIsEnabled, false)
    }

    func test_bindSaveButtonStates_statsIsChanged_saveButtonIsEnabled() {
        // Given
        let listGradingPeriods = getListGradingPeriods()
        gradeFilterInteractor.currentSortById = "dueDate"
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            gradingPeriods: listGradingPeriods,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let testee = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        testee.sortModeOptions.selected.send(.make(id: "groupName"))
        // Then
        XCTAssertEqual(testee.saveButtonIsEnabled, true)
    }

    func test_saveButtonTapped() {
        // Given
        let selectedGradingPeriodPublisher = CurrentValueRelay<String?>(nil)
        let selectedSortByPublisher = CurrentValueRelay<GradeArrangementOptions>(.groupName)
        let listGradingPeriods = getListGradingPeriods()
        let viewController = WeakViewController()
        var isSelectedGradingPeriodPublisherFired = false
        var isSelectedSortByPublisherFired = false

        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            selectedGradingPeriodPublisher: selectedGradingPeriodPublisher,
            selectedSortByPublisher: selectedSortByPublisher,
            gradingPeriods: listGradingPeriods,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let testee = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        testee.sortModeOptions.selected.send(.make(id: "groupName"))
        testee.gradingPeriodOptions.selected.send(nil)
        selectedGradingPeriodPublisher.sink { _ in
            isSelectedGradingPeriodPublisherFired = true
        }
        .store(in: &subscriptions)

        selectedSortByPublisher.sink { _ in
            isSelectedSortByPublisherFired = true
        }
        .store(in: &subscriptions)
        testee.saveButtonTapped(viewController: viewController)
        wait(for: [router.dismissExpectation], timeout: 1)
        // Then
        XCTAssertTrue(isSelectedGradingPeriodPublisherFired)
        XCTAssertTrue(isSelectedSortByPublisherFired)
    }

    private func getListGradingPeriods() -> [GradingPeriod] {
        [
            .save(.make(id: "1", title: "Spring"), courseID: "1", in: database.viewContext),
            .save(.make(id: "2", title: "Summer"), courseID: "2", in: database.viewContext),
            .save(.make(id: "3", title: "Autumn"), courseID: "3", in: database.viewContext),
            .save(.make(id: "4", title: "Winter"), courseID: "4", in: database.viewContext)
        ]
    }
}
