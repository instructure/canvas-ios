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

/// Helper type which groups together various representations of a repeating event's frequency.
struct FrequencySelection: Equatable {
    /// The frequency's definition, used by APIrequests.
    let rule: RecurrenceRule

    /// The frequency's user facing name, used on EditEvent screen.
    /// NOTE: This value is not used on SelectFrequency screen.
    let title: String?

    /// The frequency's template, either predefined or custom. It allows decoding to selectable options on SelectFrequency screen.
    let preset: FrequencyPreset

    init(_ rule: RecurrenceRule, title: String? = nil, preset: FrequencyPreset) {
        self.title = preset.isCustom ? nil : (title ?? rule.text)
        self.rule = rule
        self.preset = preset
    }
}

// MARK: - Helpers

extension CalendarEvent {

    var frequencySelection: FrequencySelection? {
        guard let recurrenceRule else { return nil }

        return FrequencySelection(
            recurrenceRule,
            title: seriesInNaturalLanguage,
            preset: frequencyPreset
        )
    }
}
