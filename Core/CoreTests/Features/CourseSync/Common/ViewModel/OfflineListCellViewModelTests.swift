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
import XCTest

class OfflineListCellViewModelTests: CoreTestCase {
    private var testee: OfflineListCellViewModel!

    override func setUp() {
        super.setUp()
        testee = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            state: .idle
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testListAccordionHeaderAttributes() {
        let testee = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            state: .idle
        )

        XCTAssertEqual(testee.backgroundColor, .backgroundLightest)
        XCTAssertEqual(testee.cellHeight, 54)
        XCTAssertEqual(testee.titleFont, .semibold16)
        XCTAssertEqual(testee.subtitleFont, .regular14)
    }

    func testMainAccordionHeaderAttributes() {
        let testee = OfflineListCellViewModel(
            cellStyle: .mainAccordionHeader,
            title: "Title",
            state: .idle
        )

        XCTAssertEqual(testee.backgroundColor, .backgroundLight)
        XCTAssertEqual(testee.cellHeight, 72)
        XCTAssertEqual(testee.titleFont, .semibold16)
        XCTAssertEqual(testee.subtitleFont, .regular14)
    }

    func testDeselectedAccessibilitySelectionText() {
        let testee = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            selectionState: .deselected,
            state: .idle
        )
        XCTAssertEqual(
            testee.accessibilitySelectionText,
            String(localized: "Select item", bundle: .core)
        )
    }

    func testSelectedAccessibilitySelectionText() {
        let testee = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            selectionState: .selected,
            state: .idle
        )
        XCTAssertEqual(
            testee.accessibilitySelectionText,
            String(localized: "Deselect item", bundle: .core)
        )
    }

    func testCollapsedAccessibilityHeaderText() {
        let testee = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            isCollapsed: true,
            state: .idle
        )
        XCTAssertEqual(
            testee.accessibilityAccordionHeaderText,
            String(localized: "Open section", bundle: .core)
        )
    }

    func testExpandedAccessibilityHeaderText() {
        let testee = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            isCollapsed: false,
            state: .idle
        )
        XCTAssertEqual(
            testee.accessibilityAccordionHeaderText,
            String(localized: "Close section", bundle: .core)
        )
    }

    func testAccessiblityText() {
        let testee = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            state: .downloaded
        )

        XCTAssertEqual(testee.accessibilityText, "Title Subtitle")
    }

    func testSelectionAccessiblityText() {
        let testee1 = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            selectionState: .deselected,
            selectionDidToggle: {},
            state: .downloaded
        )
        XCTAssertEqual(testee1.accessibilityText, "Title Subtitle, Deselected")

        let testee2 = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            selectionState: .selected,
            selectionDidToggle: {},
            state: .downloaded
        )
        XCTAssertEqual(testee2.accessibilityText, "Title Subtitle, Selected")

        let testee3 = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            selectionState: .partiallySelected,
            selectionDidToggle: {},
            state: .downloaded
        )
        XCTAssertEqual(testee3.accessibilityText, "Title Subtitle, Partially selected")
    }

    func testCollapseAccessiblityText() {
        let testee1 = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            isCollapsed: true,
            state: .downloaded
        )
        XCTAssertEqual(testee1.accessibilityText, "Title Subtitle, Closed section")

        let testee2 = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            isCollapsed: false,
            state: .downloaded
        )
        XCTAssertEqual(testee2.accessibilityText, "Title Subtitle, Open section")
    }

    func testProgressAccessiblityText() {
        let testee1 = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            state: .loading(1)
        )
        XCTAssertEqual(testee1.accessibilityText, "Title Subtitle, Download complete")

        let testee2 = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            state: .loading(0.5)
        )
        XCTAssertEqual(testee2.accessibilityText, "Title Subtitle, Downloading")
    }

    func testAccessiblityText_FollowingList() {
        let testee = OfflineListCellViewModel(
            cellStyle: .listAccordionHeader,
            title: "Title",
            subtitle: "Subtitle",
            accessibilityLabelPrefix: "some prefix",
            state: .downloaded
        )

        XCTAssertEqual(testee.accessibilityText, "some prefix, Title Subtitle")
    }
}
