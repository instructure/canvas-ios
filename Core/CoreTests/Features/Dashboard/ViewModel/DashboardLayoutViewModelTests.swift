//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
@testable import Core

class DashboardLayoutViewModelTests: CoreTestCase {

    func testGridLayoutCalculation() {
        environment.userDefaults?.isDashboardLayoutGrid = true
        let testee = DashboardLayoutViewModel(interactor: DashboardSettingsInteractorPreview())

        let smallLayout = testee.layoutInfo(for: 600, horizontalSizeClass: .compact)
        XCTAssertEqual(smallLayout.columns, 2)
        let largeLayout = testee.layoutInfo(for: 650, horizontalSizeClass: .compact)
        XCTAssertEqual(largeLayout.columns, 4)
    }

    func testListLayoutCalculation() {
        let interactor = DashboardSettingsInteractorPreview()
        interactor.layout.send(.list)
        let testee = DashboardLayoutViewModel(interactor: interactor)

        let smallLayout = testee.layoutInfo(for: 600, horizontalSizeClass: .compact)
        XCTAssertEqual(smallLayout.columns, 1)
        let largeLayout = testee.layoutInfo(for: 650, horizontalSizeClass: .compact)
        XCTAssertEqual(largeLayout.columns, 1)
    }

    func testMinHeight() {
        let interactor = DashboardSettingsInteractorPreview()
        let testee = DashboardLayoutViewModel(interactor: interactor)

        interactor.layout.send(.grid)
        var layout = testee.layoutInfo(for: 0, horizontalSizeClass: .compact)
        XCTAssertEqual(layout.cardMinHeight, 160)

        interactor.layout.send(.list)
        layout = testee.layoutInfo(for: 0, horizontalSizeClass: .regular)
        XCTAssertEqual(layout.cardMinHeight, 100)
    }

    func testIsWideLayout() {
        let interactor = DashboardSettingsInteractorPreview()
        let testee = DashboardLayoutViewModel(interactor: interactor)

        interactor.layout.send(.grid)
        var layout = testee.layoutInfo(for: 0, horizontalSizeClass: .regular)
        XCTAssertFalse(layout.isWideLayout)

        interactor.layout.send(.list)
        layout = testee.layoutInfo(for: 0, horizontalSizeClass: .regular)
        XCTAssertTrue(layout.isWideLayout)
    }
}
