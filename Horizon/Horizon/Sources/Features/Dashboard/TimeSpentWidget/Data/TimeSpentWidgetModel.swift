//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct TimeSpentWidgetModel: Identifiable, Equatable {
    let id: String
    let courseName: String
    let minutesPerDay: Int

    var formattedHours: (value: String, unit: String) {
        if minutesPerDay < 60 {
            let minute = (minutesPerDay == 1)
            ? String(localized: "minute", bundle: .horizon)
            : String(localized: "minutes", bundle: .horizon)
            return ("\(minutesPerDay)", minute)
        } else {
            let hours: Double = (Double(minutesPerDay) / 60.0).rounded()
            let hour = (hours == 1)
            ? String(localized: "hour", bundle: .horizon)
            : String(localized: "hours", bundle: .horizon)
            return (hours.trimmedString, hour)
        }
    }

    var titleAccessibilityLabel: String {
        if id == "-1" { // This refer to all courses are seleted
          return String.localizedStringWithFormat(
                String(localized: "time spent for all courses is %@ %@", bundle: .horizon),
                formattedHours.value,
                formattedHours.unit
            )
        } else {
            return String.localizedStringWithFormat(
                String(localized: "%@ time spent is %@ %@", bundle: .horizon),
                courseName,
                formattedHours.value,
                formattedHours.unit
            )
        }
    }

    var titleAccessibilityButtonLabel: String {
        if id == "-1" { // This refer to all courses are seleted
          return String.localizedStringWithFormat(
                String(localized: "all course selected", bundle: .horizon),
                formattedHours.value,
                formattedHours.unit
            )
        } else {
            return String.localizedStringWithFormat(
                String(localized: "%@ time spent selected", bundle: .horizon), courseName
            )
        }
    }

    static let loadingModels: [Self] = [
        .init(id: "1", courseName: "Introduction to SwiftUI", minutesPerDay: 125)
    ]
}

extension Array where Element == TimeSpentWidgetModel {
    var totalMinutesPerDay: Int {
        self.map { $0.minutesPerDay }.reduce(0, +)
    }
}
