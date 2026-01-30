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
import Core
import SwiftUI

protocol DashboardWidgetViewModel: AnyObject, Identifiable where ID == DashboardWidgetIdentifier {
    associatedtype ViewType: View

    var id: DashboardWidgetIdentifier { get }

    /// User configurable widget settings.
    var config: DashboardWidgetConfig { get }

    /// Non-editable, widget specific property used for layouting.
    /// Full width widgets are put at the top of the screen outside of the widget grid.
    var isFullWidth: Bool { get }

    var isEditable: Bool { get }

    /// The state helps the dashboard screen to decide if the empty state should be shown or not.
    var state: InstUI.ScreenState { get }

    /// Used by the layout to detect when widget size might change and trigger smooth animations.
    /// Override this property to include any size-affecting properties (e.g., text.count).
    /// This is required because widget view models are stored in an array and SwiftUI can't observe
    /// individual view model changes in the array.
    /// Default implementation returns state.
    var layoutIdentifier: AnyHashable { get }

    func makeView() -> ViewType

    /// When pull to refresh is performed on the dashboard each widget is asked to refresh their content.
    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never>
}

extension DashboardWidgetViewModel {
    var id: DashboardWidgetIdentifier {
        config.id
    }

    var layoutIdentifier: AnyHashable {
        AnyHashable(state)
    }
}
