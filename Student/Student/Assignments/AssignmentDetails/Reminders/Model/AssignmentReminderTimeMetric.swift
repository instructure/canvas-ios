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

public enum AssignmentReminderTimeMetric: CaseIterable, Identifiable, Hashable {
    case minutes, hours, days, weeks

    public var id: String { pickerTitle }
    public var pickerTitle: String {
        switch self {
        case .minutes: return String(localized: "Minutes Before", bundle: .student)
        case .hours: return String(localized: "Hours Before", bundle: .student)
        case .days: return String(localized: "Days Before", bundle: .student)
        case .weeks: return String(localized: "Weeks Before", bundle: .student)
        }
    }
}
