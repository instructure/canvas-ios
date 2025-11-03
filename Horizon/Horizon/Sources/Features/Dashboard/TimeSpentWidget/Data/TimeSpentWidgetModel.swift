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

import HorizonUI
import Foundation

struct TimeSpentWidgetModel: Identifiable, Equatable {
    let id: String
    let courseName: String
    let minutesPerDay: Int

    private var timeComponents: (hours: Int, mins: Int) {
        (minutesPerDay / 60, minutesPerDay % 60)
    }

    var formattedTime: AttributedString {
        var attributed = AttributedString()
        let (hours, mins) = timeComponents

        if hours > 0 {
            appendTime(
                value: hours,
                unit: hours == 1 ? String(localized: "hr") : String(localized: "hrs"),
                to: &attributed
            )

            if mins > 0 {
                attributed.append(AttributedString(" "))
                appendTime(
                    value: mins,
                    unit: mins == 1 ? String(localized: "min") : String(localized: "mins"),
                    to: &attributed
                )
            }
        } else {
            appendTime(
                value: mins,
                unit: mins == 1 ? String(localized: "min") : String(localized: "mins"),
                to: &attributed
            )
        }

        return attributed
    }

    private func appendTime(value: Int, unit: String, to attributed: inout AttributedString) {
        var number = AttributedString("\(value)")
        number.font = HorizonUI.Typography(.labelSemibold).fount

        var label = AttributedString(" \(unit)")
        label.font = HorizonUI.Typography(.labelSmallBold).fount
        label.baselineOffset = 8 // keeps units visually centered
        attributed.append(number)
        attributed.append(label)
    }

    // MARK: - Accessibility

    private var accessibilityTimeDescription: String {
        let (hours, mins) = timeComponents
        var components: [String] = []

        if hours > 0 {
            let unit = hours == 1 ? String(localized: "hour") : String(localized: "hours")
            components.append("\(hours) \(unit)")
        }

        if mins > 0 {
            let unit = mins == 1 ? String(localized: "minute") : String(localized: "minutes")
            components.append("\(mins) \(unit)")
        }

        return components.isEmpty
        ? String(localized: "0 minutes")
        : components.joined(separator: " ")
    }

    var accessibilityCourseTimeSpent: String {
            if id == "-1" { // refer to all courses seleted
                return String.localizedStringWithFormat(
                     String(localized: "Time spent for all courses is %@", bundle: .horizon),
                     accessibilityTimeDescription
                 )
            } else {
               return String.localizedStringWithFormat(
                    String(localized: "Time spent for course %@ is %@", bundle: .horizon),
                    courseName,
                    accessibilityTimeDescription
                )
            }
    }

    var titleAccessibilityLabel: String {
        if id == "-1" {
            // "All courses selected"
            return String.localizedStringWithFormat(
                String(localized: "total time spent is %@", bundle: .horizon),
                accessibilityTimeDescription
            )
        } else {
            return String.localizedStringWithFormat(
                String(localized: "%@ time spent is %@", bundle: .horizon),
                courseName,
                accessibilityTimeDescription
            )
        }
    }

    var titleAccessibilityButtonLabel: String {
        if id == "-1" { // This refer to all courses are seleted
            return String(localized: "total selected", bundle: .horizon)
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
