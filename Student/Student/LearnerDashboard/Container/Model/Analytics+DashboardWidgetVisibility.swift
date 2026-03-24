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

import Core
import Foundation

extension EditableWidgetIdentifier {
    var analyticsID: String {
        switch self {
        case .helloWidget: "welcome"
        case .coursesAndGroups: "courses"
        case .weeklySummary: "forecast"
        case .todo: "todo"
        }
    }
}

extension Analytics {
    func logDashboardWidgetVisibility(_ event: DashboardWidgetVisibilityEvent) {
        logEvent(event.analyticsEventName, parameters: event.params)
    }
}

struct DashboardWidgetVisibilityEvent {
    let analyticsEventName = "dashboard_widget_visibility"
    let params: [String: Any]

    init(configs: [DashboardWidgetConfig]) {
        let visibleConfigs = configs.filter { $0.isVisible }.sorted()
        params = Dictionary(uniqueKeysWithValues: configs.map { config in
            let position = visibleConfigs.firstIndex(where: { $0.id == config.id })
            return (config.id.analyticsID, position.map(String.init) ?? "-1")
        })
    }
}
