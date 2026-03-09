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

// Widgets that appear at the top of the dashboard in declaration order when they have content to show.
// The user cannot reorder or hide these.
enum SystemWidgetIdentifier: String, CaseIterable {
    case offlineSyncProgress
    case fileUploadProgress
    case courseInvitations
    case globalAnnouncements
    case conferences
}

// User-configurable widgets whose visibility and order can be changed in dashboard settings.
// The declaration order defines the default display order when no saved configuration exists.
enum EditableWidgetIdentifier: String, Codable, CaseIterable {
    case helloWidget
    case coursesAndGroups

    func settingsTitle(username: String) -> String {
        switch self {
        case .helloWidget: String(localized: "Hello \(username)", bundle: .student)
        case .coursesAndGroups: String(localized: "Courses & Groups", bundle: .student)
        }
    }
}
