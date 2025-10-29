//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import SwiftUI

extension EnvironmentValues {
    @Entry public var isItemSelected = false
}

extension View {
        /// This View Modifier sets the `isSelected` Environment Value on a view.
        /// /// If the Split View Controller is collapsed, it always sets it to `false`.
    public func selected(when condition: Bool) -> some View {
        modifier(ItemSelectionModifier(isSelected: condition))
    }

        /// This View Modifier sets the `isSelected` Environment Value on a view to `false`.
    public func selectionIndicatorDisabled() -> some View {
        self.environment(\.isItemSelected, false)
    }
}

private struct ItemSelectionModifier: ViewModifier {
    @Environment(\.viewController) var controller
    let isSelected: Bool

    func body(content: Content) -> some View {
        let isSplitViewControllerCollapsed = controller.value.splitViewController?.isCollapsed ?? true

        content
            .environment(\.isItemSelected, isSplitViewControllerCollapsed && isSelected)
    }
}
