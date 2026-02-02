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

struct DashboardWidgetConfig: Codable, Comparable, Identifiable {
    let id: DashboardWidgetIdentifier
    var order: Int
    var isVisible: Bool
    /// Widget-specific settings encoded into a JSON to be persisted.
    var settings: String?

    static func < (lhs: DashboardWidgetConfig, rhs: DashboardWidgetConfig) -> Bool {
        lhs.order < rhs.order
    }
}

extension Array where Element == DashboardWidgetConfig {
    func partitionedByLayout(
        isFullWidth: (DashboardWidgetConfig) -> Bool
    ) -> (fullWidth: [DashboardWidgetConfig], grid: [DashboardWidgetConfig]) {
        let fullWidth = filter { isFullWidth($0) }.sorted()
        let grid = filter { !isFullWidth($0) }.sorted()
        return (fullWidth, grid)
    }
}
