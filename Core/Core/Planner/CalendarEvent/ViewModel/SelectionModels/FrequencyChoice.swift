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

struct FrequencyChoice: Identifiable {

    static func allCases(given date: Date) -> [FrequencyChoice] {
        return FrequencyPreset
            .choicesPresets
            .map { FrequencyChoice(date: date, preset: $0) }
    }

    let id = Foundation.UUID()
    let date: Date
    let preset: FrequencyPreset

    init(date: Date, preset: FrequencyPreset) {
        self.date = date
        self.preset = preset
    }

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
        case .selected(let seriesTitle, let rule):
            return seriesTitle ?? rule.text
        case .custom:
            return String(localized: "Custom", bundle: .core) // Should not fall to this case
        }
    }
}

extension FrequencyPreset {
    static let choicesPresets: [FrequencyPreset] = [.noRepeat] + calculativePresets
}
