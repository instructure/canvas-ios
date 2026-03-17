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

import Combine
@testable import Core
@testable import Student
import SwiftUI
import XCTest

final class DashboardWidgetViewModelArrayTests: XCTestCase {

    // MARK: - allEditableWidgetsTurnedOff

    func test_allEditableWidgetsTurnedOff_withEmptyArray_shouldBeTrue() {
        let widgets: [any DashboardWidgetViewModel] = []

        XCTAssertTrue(widgets.allEditableWidgetsTurnedOff)
    }

    func test_allEditableWidgetsTurnedOff_withOnlySystemWidgets_shouldBeTrue() {
        let widgets: [any DashboardWidgetViewModel] = [
            MockDashboardWidgetViewModel(id: SystemWidgetIdentifier.courseInvitations.rawValue)
        ]

        XCTAssertTrue(widgets.allEditableWidgetsTurnedOff)
    }

    func test_allEditableWidgetsTurnedOff_withEditableWidget_shouldBeFalse() {
        let widgets: [any DashboardWidgetViewModel] = [
            MockDashboardWidgetViewModel(id: EditableWidgetIdentifier.helloWidget.rawValue)
        ]

        XCTAssertFalse(widgets.allEditableWidgetsTurnedOff)
    }

    func test_allEditableWidgetsTurnedOff_withSystemAndEditableWidgets_shouldBeFalse() {
        let widgets: [any DashboardWidgetViewModel] = [
            MockDashboardWidgetViewModel(id: SystemWidgetIdentifier.courseInvitations.rawValue),
            MockDashboardWidgetViewModel(id: EditableWidgetIdentifier.coursesAndGroups.rawValue)
        ]

        XCTAssertFalse(widgets.allEditableWidgetsTurnedOff)
    }
}

private final class MockDashboardWidgetViewModel: DashboardWidgetViewModel {
    let id: String
    let state: InstUI.ScreenState = .data
    let isHiddenInEmptyState = false

    init(id: String) {
        self.id = id
    }

    func makeView() -> AnyView { AnyView(EmptyView()) }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }
}
