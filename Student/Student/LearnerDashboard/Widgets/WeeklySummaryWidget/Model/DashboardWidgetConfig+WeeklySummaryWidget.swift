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

import Foundation

struct WeeklySummaryWidgetSettings: Codable {
    var expandedFilterId: String?
}

extension DashboardWidgetConfig {
    var weeklySummarySettings: WeeklySummaryWidgetSettings {
        get {
            guard let json = settings, let data = json.data(using: .utf8) else { return WeeklySummaryWidgetSettings() }
            return (try? JSONDecoder().decode(WeeklySummaryWidgetSettings.self, from: data)) ?? WeeklySummaryWidgetSettings()
        }
        set {
            settings = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) }
        }
    }
}
