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

import Foundation

enum DashboardWidgetIdentifier: String, Codable, CaseIterable {
    case offlineSyncProgress
    case fileUploadProgress
    case conferences
    case courseInvitations
    case globalAnnouncements
    case helloWidget

    case weeklySummary
    case coursesAndGroups
    case toDo

    func title(username: String) -> String {
        switch self {
        case .conferences: return String(localized: "Conferences", bundle: .student)
        case .helloWidget: return String(localized: "Hello \(username)", bundle: .student)
        case .weeklySummary: return String(localized: "Weekly Summary", bundle: .student)
        case .coursesAndGroups: return String(localized: "Courses & Groups", bundle: .student)
        case .toDo: return String(localized: "Daily To-do", bundle: .student)
        case .offlineSyncProgress, .fileUploadProgress, .globalAnnouncements, .courseInvitations:
            assertionFailure("\(self) widget should not appear among Dashboard settings")
            return rawValue
        }
    }

    var isEditable: Bool {
        switch self {
        case .offlineSyncProgress, .fileUploadProgress, .globalAnnouncements, .courseInvitations:
            false
        case .conferences, .helloWidget, .weeklySummary, .coursesAndGroups, .toDo:
            true
        }
    }
}
