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

public enum CalendarFilterCountLimit: Equatable {
    case base
    case extended(Int)
    case unlimited

    public var rawValue: Int {
        switch self {
        case .base: return 10
        case .extended(let value): return value
        case .unlimited: return 9999
        }
    }
}

public extension Optional where Wrapped == AppEnvironment.App {

    var isCalendarFilterLimitEnabled: Bool {
        switch self {
        case .teacher: return true
        case .none, .parent, .student, .horizon: return false
        }
    }
}

public extension Optional where Wrapped == CDEnvironmentSettings {

    func calendarFilterCountLimit(
        isCalendarFilterLimitEnabled: Bool
    ) -> CalendarFilterCountLimit {
        guard isCalendarFilterLimitEnabled else {
            return .unlimited
        }

        if let limit = self?.calendarContextsLimit {
            return .extended(limit)
        }

        return .base
    }
}
