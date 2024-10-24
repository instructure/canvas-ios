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

struct FrequencyPresetViewModel: Identifiable {

    let id = Foundation.UUID()
    let preset: FrequencyPreset?

    private let date: Date

    init(preset: FrequencyPreset?, date: Date) {
        self.preset = preset
        self.date = date
    }

    /// This `title` is a simplified one, intended only for the SelectFrequency screen.
    /// It may not match the title coming from backend or the one calculated from the rule.
    var title: String {
        switch preset {
        case .noRepeat:
            return String(localized: "Does Not Repeat", bundle: .core)
        case .daily:
            return String(localized: "Daily", bundle: .core)
        case .weeklyOnThatDay:
            return String(localized: "Weekly on %@", bundle: .core)
                .asFormat(for: date.formatted(format: "EEEE"))
        case .monthlyOnThatWeekday:
            let weekday = date.monthWeekday
            return String(localized: "Monthly on %@", bundle: .core)
                .asFormat(for: weekday.middleText)
        case .yearlyOnThatMonth:
            return String(localized: "Annually on %@", bundle: .core)
                .asFormat(for: date.formatted(format: "MMMM d"))
        case .everyWeekday:
            return String(localized: "Every Weekday (Monday to Friday)", bundle: .core)
        case .selected(let title, _):
            return title
        case .custom, .none:
            return String(localized: "Custom", bundle: .core)
        }
    }
}
