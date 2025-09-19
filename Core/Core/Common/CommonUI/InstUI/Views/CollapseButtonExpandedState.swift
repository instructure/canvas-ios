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

import Foundation

extension InstUI {

    /// Provides accessibility strings for the given state of a Collapes/Expand button.
    public struct CollapseButtonExpandedState {
        private let isExpanded: Bool

        public init(isExpanded: Bool) {
            self.isExpanded = isExpanded
        }

        public var a11yValue: String {
            isExpanded ? Self.expanded.a11yValue : Self.collapsed.a11yValue
        }

        public var a11yHint: String {
            isExpanded ? Self.expanded.a11yHint : Self.collapsed.a11yHint
        }

        public var a11yActionLabel: String {
            isExpanded ? Self.expanded.a11yActionLabel : Self.collapsed.a11yActionLabel
        }
    }
}

// MARK: - Strings

extension InstUI.CollapseButtonExpandedState {
    public static let expanded = (
        a11yValue: [
            "", // to add a pause before value
            String(localized: "Expanded", bundle: .core)
        ].accessibilityJoined(),
        a11yHint: String(localized: "Double-tap to collapse", bundle: .core),
        a11yActionLabel: String(localized: "Collapse", bundle: .core)
    )

    public static let collapsed = (
        a11yValue: [
            "", // to add a pause before value
            String(localized: "Collapsed", bundle: .core)
        ].accessibilityJoined(),
        a11yHint: String(localized: "Double-tap to expand", bundle: .core),
        a11yActionLabel: String(localized: "Expand", bundle: .core)
    )
}
