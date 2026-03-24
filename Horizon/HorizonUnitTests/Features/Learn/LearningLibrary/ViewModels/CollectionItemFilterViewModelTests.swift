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

final class CollectionItemFilterViewModelTests: HorizonTestCase {

    // MARK: - Initialization Tests

    func testInitWithNoPreselectionSetsDefaults() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            onSetSortOption: { _, _ in }
        )

        XCTAssertNil(testee.selectedSortOption)
        XCTAssertEqual(testee.selectedFilterTypes, [.all])
    }

    func testInitWithPreselectionSetsValues() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedSortOption: .mostRecent,
            selectedFilterTypes: [.course, .assignment],
            onSetSortOption: { _, _ in }
        )

        XCTAssertEqual(testee.selectedSortOption, .mostRecent)
        XCTAssertEqual(testee.selectedFilterTypes, [.course, .assignment])
    }

    func testInitWithNilFilterTypesDefaultsToAll() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedSortOption: .nameAZ,
            selectedFilterTypes: nil,
            onSetSortOption: { _, _ in }
        )

        XCTAssertEqual(testee.selectedSortOption, .nameAZ)
        XCTAssertEqual(testee.selectedFilterTypes, [.all])
    }

    // MARK: - Sort Option Toggle Tests

    func testToggleSortOptionSelectsNewOption() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            onSetSortOption: { _, _ in }
        )

        testee.toggleSortOption(.mostRecent)

        XCTAssertEqual(testee.selectedSortOption, .mostRecent)
    }

    func testToggleSortOptionDeselectsCurrentOption() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedSortOption: .mostRecent,
            onSetSortOption: { _, _ in }
        )

        testee.toggleSortOption(.mostRecent)

        XCTAssertNil(testee.selectedSortOption)
    }

    func testToggleSortOptionSwitchesOptions() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedSortOption: .mostRecent,
            onSetSortOption: { _, _ in }
        )

        testee.toggleSortOption(.nameAZ)

        XCTAssertEqual(testee.selectedSortOption, .nameAZ)
    }

    // MARK: - Filter Type Toggle Tests

    func testToggleFilterTypeAllSelectsOnlyAll() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedFilterTypes: [.course, .assignment],
            onSetSortOption: { _, _ in }
        )

        testee.toggleFilterType(.all)

        XCTAssertEqual(testee.selectedFilterTypes, [.all])
    }

    func testToggleFilterTypeDeselectsItemAndAddsOthers() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedFilterTypes: [.course, .assignment],
            onSetSortOption: { _, _ in }
        )

        testee.toggleFilterType(.course)

        XCTAssertTrue(testee.selectedFilterTypes.contains(.assignment))
        XCTAssertFalse(testee.selectedFilterTypes.contains(.course))
    }

    func testToggleFilterTypeDeselectsLastItemResetsToAll() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedFilterTypes: [.course],
            onSetSortOption: { _, _ in }
        )

        testee.toggleFilterType(.course)

        XCTAssertEqual(testee.selectedFilterTypes, [.all])
    }

    func testToggleFilterTypeSelectsItemRemovesAll() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedFilterTypes: [.all],
            onSetSortOption: { _, _ in }
        )

        testee.toggleFilterType(.course)

        XCTAssertTrue(testee.selectedFilterTypes.contains(.course))
        XCTAssertFalse(testee.selectedFilterTypes.contains(.all))
        XCTAssertEqual(testee.selectedFilterTypes.count, 1)
    }

    func testToggleFilterTypeAddsMultipleItems() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedFilterTypes: [.all],
            onSetSortOption: { _, _ in }
        )

        testee.toggleFilterType(.course)
        testee.toggleFilterType(.assignment)

        XCTAssertTrue(testee.selectedFilterTypes.contains(.course))
        XCTAssertTrue(testee.selectedFilterTypes.contains(.assignment))
        XCTAssertFalse(testee.selectedFilterTypes.contains(.all))
        XCTAssertEqual(testee.selectedFilterTypes.count, 2)
    }

    // MARK: - Clear Filter Tests

    func testClearFilterResetsAllValues() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedSortOption: .mostRecent,
            selectedFilterTypes: [.course, .assignment],
            onSetSortOption: { _, _ in }
        )

        testee.clearFilter(viewController: WeakViewController(UIViewController()))

        XCTAssertNil(testee.selectedSortOption)
        XCTAssertEqual(testee.selectedFilterTypes, [.all])
    }

    // MARK: - Dismiss Tests

    func testDismissCallsCallbackWithSelectedValues() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedSortOption: .mostRecent,
            selectedFilterTypes: [.course, .assignment],
            onSetSortOption: { sort, filters in
                XCTAssertNil(sort)
                XCTAssertNil(filters)

            }
        )
        testee.dismiss(viewController: WeakViewController(UIViewController()))
        XCTAssertNotNil(router.dismissed)
    }

    func testDismissCallsCallbackWithNilWhenOnlyAllSelected() {
        let testee = CollectionItemFilterViewModel(
            router: router,
            selectedSortOption: nil,
            selectedFilterTypes: [.all],
            onSetSortOption: { _, _ in }
        )

        testee.dismiss(viewController: WeakViewController(UIViewController()))
        XCTAssertNotNil(router.dismissed)
    }
}
