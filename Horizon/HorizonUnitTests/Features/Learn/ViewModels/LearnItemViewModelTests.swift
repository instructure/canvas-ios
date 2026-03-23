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

final class LearnItemViewModelTests: HorizonTestCase {

    // MARK: - Accessibility Announcement Tests

    func testAnnouncesNoResultsFound() {
        let scheduler = DispatchQueue.test
        let interactor = LearnItemInteractorMock(itemsToReturn: [])
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.completed],
            scheduler: scheduler.eraseToAnyScheduler()
        )
        var receivedMessages: [String] = []
        var cancellables = Set<AnyCancellable>()
        testee.accessibilityMessagePublisher.sink { message in
            receivedMessages.append(message)
        }.store(in: &cancellables)

        testee.searchText = "NonExistent"
        scheduler.advance(by: .milliseconds(500))

        XCTAssertTrue(receivedMessages.contains("No results found"))
    }

    func testAnnouncesOneResult() {
        let mockItem = LearnItemModel(
            id: "item-1",
            name: "Swift Course",
            completionPercentage: 50,
            position: 1,
            startAt: nil,
            endAt: nil,
            imageUrl: nil,
            estimatedDurationMinutes: nil,
            courseCount: nil,
            itemType: .course,
            enrollmentId: "enrollment-1",
            nextModuleItemID: nil
        )
        let scheduler = DispatchQueue.test
        let interactor = LearnItemInteractorMock(itemsToReturn: [mockItem])
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.notStarted],
            scheduler: scheduler.eraseToAnyScheduler()
        )
        var receivedMessages: [String] = []
        var cancellables = Set<AnyCancellable>()
        testee.accessibilityMessagePublisher.sink { message in
            receivedMessages.append(message)
        }.store(in: &cancellables)

        testee.searchText = "Swift"
        scheduler.advance(by: .milliseconds(500))

        XCTAssertTrue(receivedMessages.contains("Found 1 result"))
    }

    func testAnnouncesMultipleResults() {
        let mockItems = [
            LearnItemModel(
                id: "item-1",
                name: "Swift Course",
                completionPercentage: 50,
                position: 1,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .course,
                enrollmentId: "enrollment-1",
                nextModuleItemID: nil
            ),
            LearnItemModel(
                id: "item-2",
                name: "iOS Development",
                completionPercentage: 30,
                position: 2,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .course,
                enrollmentId: "enrollment-2",
                nextModuleItemID: nil
            ),
            LearnItemModel(
                id: "item-3",
                name: "Mobile Development Program",
                completionPercentage: 75,
                position: 3,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .program,
                enrollmentId: "enrollment-3",
                nextModuleItemID: nil
            )
        ]
        let scheduler = DispatchQueue.test
        let interactor = LearnItemInteractorMock(itemsToReturn: mockItems)
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: scheduler.eraseToAnyScheduler()
        )
        var receivedMessages: [String] = []
        var cancellables = Set<AnyCancellable>()
        testee.accessibilityMessagePublisher.sink { message in
            receivedMessages.append(message)
        }.store(in: &cancellables)

        testee.searchText = "Development"
        scheduler.advance(by: .milliseconds(500))

        XCTAssertTrue(receivedMessages.contains { $0.contains("Found 3 results") })
    }

    // MARK: - Fetch Items Tests

    func testGetLearnItemSuccessHidesLoader() {
        let mockItem = LearnItemModel(
            id: "item-1",
            name: "Swift Course",
            completionPercentage: 50,
            position: 1,
            startAt: nil,
            endAt: nil,
            imageUrl: nil,
            estimatedDurationMinutes: nil,
            courseCount: nil,
            itemType: .course,
            enrollmentId: "enrollment-1",
            nextModuleItemID: nil
        )
        let interactor = LearnItemInteractorMock(itemsToReturn: [mockItem])
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.completed],
            scheduler: .immediate
        )

        testee.getLearnItem()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertEqual(testee.filteredItems.count, 1)
    }

    func testGetLearnItemErrorShowsError() {
        let interactor = LearnItemInteractorMock(shouldFail: true)
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.notStarted],
            scheduler: .immediate
        )

        testee.getLearnItem()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.isErrorVisible)
        XCTAssertFalse(testee.errorMessage.isEmpty)
    }

    func testRefreshReloadsData() async {
        let mockItems = [
            LearnItemModel(
                id: "item-1",
                name: "Swift Course",
                completionPercentage: 50,
                position: 1,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .course,
                enrollmentId: "enrollment-1",
                nextModuleItemID: nil
            ),
            LearnItemModel(
                id: "item-2",
                name: "iOS Development",
                completionPercentage: 30,
                position: 2,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .course,
                enrollmentId: "enrollment-2",
                nextModuleItemID: nil
            )
        ]
        let interactor = LearnItemInteractorMock(itemsToReturn: mockItems)
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        await testee.refresh()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertEqual(testee.filteredItems.count, 2)
        XCTAssertTrue(testee.hasItems)
    }

    // MARK: - Filter Tests

    func testHasActiveFiltersWithNoFilters() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        XCTAssertFalse(testee.hasActiveFilters)
    }

    func testHasActiveFiltersWithSearchText() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.searchText = "Swift"

        XCTAssertTrue(testee.hasActiveFilters)
    }

    func testHasActiveFiltersWithFilterTypes() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.selectedFilterTypes = [.course]

        XCTAssertTrue(testee.hasActiveFilters)
    }

    func testAppliedFiltersCountWithNoFilters() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        XCTAssertEqual(testee.appliedFiltersCount, 0)
    }

    func testAppliedFiltersCountWithSortOption() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.selectedSortOption = .nameAZ

        XCTAssertEqual(testee.appliedFiltersCount, 1)
    }

    func testAppliedFiltersCountWithFilterTypes() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.selectedFilterTypes = [.course, .program]

        XCTAssertEqual(testee.appliedFiltersCount, 2)
    }

    func testAppliedFiltersCountWithBothSortAndFilters() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.selectedSortOption = .nameAZ
        testee.selectedFilterTypes = [.course, .program]

        XCTAssertEqual(testee.appliedFiltersCount, 3)
    }

    func testShowFilterPreservesCurrentFilterState() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.selectedSortOption = .nameAZ
        testee.selectedFilterTypes = [.course]
        let initialSortOption = testee.selectedSortOption
        let initialFilterTypes = testee.selectedFilterTypes

        testee.showFilter(viewController: WeakViewController(UIViewController()))

        XCTAssertEqual(testee.selectedSortOption, initialSortOption)
        XCTAssertEqual(testee.selectedFilterTypes, initialFilterTypes)
        let presentedViewController = router.lastViewController as? CoreHostingController<LearnItemFilterView>
        XCTAssertNotNil(presentedViewController)
    }

    func testNavigateToProgramDetails() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.navigateToProgramDetails(id: "111", viewController: WeakViewController(UIViewController()))
        let presentedViewController = router.lastViewController as? CoreHostingController<ProgramDetailsView>
        XCTAssertNotNil(presentedViewController)
    }

    func testNavigateToCourseDetails() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.navigateToCourseDetails(
            id: "12",
            enrollmentID: "222",
            programName: "Name",
            viewController: WeakViewController(UIViewController())
        )
        let presentedViewController = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(presentedViewController)
    }

    func testNNavigateToItemSequence() {
        let interactor = LearnItemInteractorMock()
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.navigateToItemSequence(
            courseID: "12",
            moduleItemID: "111",
            viewController: WeakViewController(UIViewController())
        )
        XCTAssertTrue(router.calls[0].0?.url?.absoluteString.contains("courses/12/modules/items/111") == true )
        XCTAssertEqual(router.calls.count, 1)
    }

    func testApplyingFiltersTriggersDataReload() {
        let mockItems = [
            LearnItemModel(
                id: "item-1",
                name: "Swift Course",
                completionPercentage: 50,
                position: 1,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .course,
                enrollmentId: "enrollment-1",
                nextModuleItemID: nil
            )
        ]
        let interactor = LearnItemInteractorMock(itemsToReturn: mockItems)
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )
        testee.getLearnItem()
        XCTAssertFalse(testee.isLoaderVisible)

        testee.selectedSortOption = .nameAZ
        testee.selectedFilterTypes = [.course]
        testee.getLearnItem()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertEqual(testee.appliedFiltersCount, 2)
    }

    // MARK: - Pagination Tests

    func testIsSeeMoreVisibleWhenMoreItemsAvailable() {
        let items = (1...10).map { i in
            LearnItemModel(
                id: "item-\(i)",
                name: "Course \(i)",
                completionPercentage: 50,
                position: i,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .course,
                enrollmentId: "enrollment-\(i)",
                nextModuleItemID: nil
            )
        }
        let interactor = LearnItemInteractorMock(itemsToReturn: items)
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.getLearnItem()

        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    func testIsSeeMoreVisibleWhenFewerItemsThanPageSize() {
        let items = [
            LearnItemModel(
                id: "item-1",
                name: "Course 1",
                completionPercentage: 50,
                position: 1,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .course,
                enrollmentId: "enrollment-1",
                nextModuleItemID: nil
            )
        ]
        let interactor = LearnItemInteractorMock(itemsToReturn: items)
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )

        testee.getLearnItem()

        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func testSeeMoreShowsMoreItems() {
        let items = (1...10).map { i in
            LearnItemModel(
                id: "item-\(i)",
                name: "Course \(i)",
                completionPercentage: 50,
                position: i,
                startAt: nil,
                endAt: nil,
                imageUrl: nil,
                estimatedDurationMinutes: nil,
                courseCount: nil,
                itemType: .course,
                enrollmentId: "enrollment-\(i)",
                nextModuleItemID: nil
            )
        }
        let interactor = LearnItemInteractorMock(itemsToReturn: items)
        let testee = LearnItemViewModel(
            router: router,
            interactor: interactor,
            status: [.inProgress],
            scheduler: .immediate
        )
        testee.getLearnItem()
        let initialCount = testee.filteredItems.count

        testee.seeMore()

        XCTAssertGreaterThan(testee.filteredItems.count, initialCount)
    }
}

// MARK: - Mock Initializer Extension

extension LearnItemInteractorMock {
    convenience init(itemsToReturn: [LearnItemModel] = [], shouldFail: Bool = false) {
        self.init()
        self.itemsToReturn = itemsToReturn
        self.shouldFail = shouldFail
    }
}
