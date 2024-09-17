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

    private var sut: GradeFilterViewModel!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            selectedSortBy: GradeArrangementOptions.dueDate,
            sortByOptions: GradeArrangementOptions.allCases
        )
        sut = GradeFilterViewModel(dependency: dependency)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_mapGradingPeriod_hasFiveItemsAndAddAllItem() {
        // Given
        let listGradingPeriods = getListGradingPeriods()
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            gradingPeriods: listGradingPeriods,
            selectedGradingPeriod: nil,
            selectedSortBy: GradeArrangementOptions.dueDate,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let sut = GradeFilterViewModel(dependency: dependency)
        // Then
        XCTAssertEqual(sut.gradingPeriods.first?.title, "All")
        XCTAssertEqual(sut.gradingPeriods.count, 5)
        XCTAssertTrue(sut.isShowGradingPeriodsView)
        XCTAssertEqual(sut.selectedGradingPeriod?.title, "All")
    }

    func test_mapGradingPeriod_hasSelectedGradingPeriods() {
        // Given
        let listGradingPeriods = getListGradingPeriods()
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            gradingPeriods: listGradingPeriods,
            selectedGradingPeriod: listGradingPeriods.last,
            selectedSortBy: GradeArrangementOptions.dueDate,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let sut = GradeFilterViewModel(dependency: dependency)
        // Then
        XCTAssertEqual(sut.gradingPeriods.count, 5)
        XCTAssertTrue(sut.isShowGradingPeriodsView)
        XCTAssertEqual(sut.selectedGradingPeriod?.title, listGradingPeriods.last?.title)
    }

    func test_mapGradingPeriod_notHasGradingPeriods_hideGradingPeriodSection() {
        // Given
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: false,
            gradingPeriods: nil,
            selectedGradingPeriod: nil,
            selectedSortBy: GradeArrangementOptions.dueDate,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let sut = GradeFilterViewModel(dependency: dependency)
        // Then
        XCTAssertTrue(sut.gradingPeriods.isEmpty)
        XCTAssertFalse(sut.isShowGradingPeriodsView)
    }

    func test_mapSortByOptions() {
        // Given
        let sortByOptions = GradeArrangementOptions.allCases
        let selectedSortBy = GradeArrangementOptions.dueDate
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: false,
            gradingPeriods: nil,
            selectedGradingPeriod: nil,
            selectedSortBy: selectedSortBy,
            sortByOptions: sortByOptions
        )
        // Then
        let sut = GradeFilterViewModel(dependency: dependency)
        XCTAssertEqual(sut.sortByOptions.count, 2)
        XCTAssertEqual(sut.selectedSortByOption, selectedSortBy)
    }

    func test_bindSaveButtonStates_statesNotChanged_saveButtonIsDisabled() {
        // Given
        let listGradingPeriods = getListGradingPeriods()
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            gradingPeriods: listGradingPeriods,
            selectedGradingPeriod: listGradingPeriods.last,
            selectedSortBy: GradeArrangementOptions.dueDate,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let sut = GradeFilterViewModel(dependency: dependency)
        // Then
        XCTAssertFalse(sut.saveButtonIsEnabled)

    }

    func test_bindSaveButtonStates_statsIsChanged_saveButtonIsEnabled() {
        // Given
        let listGradingPeriods = getListGradingPeriods()
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: true,
            gradingPeriods: listGradingPeriods,
            selectedGradingPeriod: listGradingPeriods.last,
            selectedSortBy: GradeArrangementOptions.dueDate,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let sut = GradeFilterViewModel(dependency: dependency)
        sut.selectedSortByOption = .groupName
        // Then
        XCTAssertTrue(sut.saveButtonIsEnabled)
    }

    func test_saveButtonTapped() {
        // Given
        var selectedGradingPeriodPublisher = PassthroughRelay<GradingPeriod?>()
        var selectedSortByPublisher = CurrentValueRelay<GradeArrangementOptions>(.groupName)
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
            selectedGradingPeriod: listGradingPeriods.last,
            selectedSortBy: GradeArrangementOptions.dueDate,
            sortByOptions: GradeArrangementOptions.allCases
        )
        // When
        let sut = GradeFilterViewModel(dependency: dependency)
        sut.selectedSortByOption = .groupName
        sut.selectedGradingPeriod = nil
        selectedGradingPeriodPublisher.sink { _ in
            isSelectedGradingPeriodPublisherFired = true
        }
        .store(in: &subscriptions)

        selectedSortByPublisher.sink { _ in
            isSelectedSortByPublisherFired = true
        }
        .store(in: &subscriptions)
        sut.saveButtonTapped(viewController: viewController)
        wait(for: [router.dismissExpectation], timeout: 1)
        // Then
        XCTAssertTrue(isSelectedGradingPeriodPublisherFired)
        XCTAssertTrue(isSelectedSortByPublisherFired)
    }

    private func getListGradingPeriods() -> [GradingPeriod] {
        [
            .save(.make(title: "Spring"), courseID: "1", in: database.viewContext),
            .save(.make(title: "Summer"), courseID: "2", in: database.viewContext),
            .save(.make(title: "Autumn"), courseID: "3", in: database.viewContext),
            .save(.make(title: "Winter"), courseID: "4", in: database.viewContext)
        ]
    }
}
