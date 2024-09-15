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

struct FrequencySelection: Equatable {
    let value: RecurrenceRule
    let title: String
    let preset: FrequencyPreset

    init(_ value: RecurrenceRule, title: String? = nil, preset: FrequencyPreset) {
        let customTitle: String? = preset.isCustom
            ? String(localized: "Custom", bundle: .core)
            : nil
        self.title = title ?? customTitle ?? value.text
        self.value = value
        self.preset = preset
    }
}

// MARK: - Helpers

extension CalendarEvent {

    var frequencySelection: FrequencySelection? {
        guard let rrule = repetitionRule
            .flatMap({ RecurrenceRule(rruleDescription: $0) })
        else { return nil }

        return FrequencySelection(
            rrule,
            title: seriesInNaturalLanguage,
            preset: frequencyPreset)
    }
}
