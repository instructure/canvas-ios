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

import SwiftUI

/// Represents a selectable option and its properties required to display it.
public struct OptionItem: Equatable, Hashable, Identifiable {

    /// A common id to support an "All" option which is typically represented as `nil` so it has no relevant `id`.
    public static let allId = "_this_is_an_unlikely_id_preserved_for_the_all_option_"

    public let id: String
    public let title: String
    public let subtitle: String?
    public let color: Color
    public let accessoryIcon: Image?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        color: Color? = nil,
        accessoryIcon: Image? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.color = color ?? Color(uiColor: Brand.shared.primary)
        self.accessoryIcon = accessoryIcon
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#if DEBUG
extension OptionItem {
    static func make(
        id: String = "",
        title: String = "",
        subtitle: String? = nil,
        color: Color? = nil,
        accessoryIcon: Image? = nil
    ) -> OptionItem {
        return OptionItem(id: id, title: title, subtitle: subtitle, color: color, accessoryIcon: accessoryIcon)
    }
}
#endif
