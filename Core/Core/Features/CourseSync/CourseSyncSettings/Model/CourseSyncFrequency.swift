//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public enum CourseSyncFrequency: Int, CaseIterable {
    #if DEBUG
    case osBased
    #endif
    case daily
    case weekly

    var stringValue: String {
        switch self {
        #if DEBUG
        case .osBased: return "As frequent as the OS allows (DEBUG)"
        #endif
        case .daily: return String(localized: "Daily", bundle: .core)
        case .weekly: return String(localized: "Weekly", bundle: .core)
        }
    }

    func nextSyncDate(from date: Date) -> Date {
        switch self {
        #if DEBUG
        case .osBased: return date
        #endif
        case .daily: return date.addingTimeInterval(24 * 60 * 60)
        case .weekly: return date.addingTimeInterval(7 * 24 * 60 * 60)
        }
    }

    static var itemPickerData: [ItemPickerItem] {
        allCases.map { ItemPickerItem(title: $0.stringValue) }
    }
}
