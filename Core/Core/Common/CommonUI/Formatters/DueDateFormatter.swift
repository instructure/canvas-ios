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

public enum DueDateFormatter {

    public static func format(_ dueDate: Date?, lockDate: Date? = nil, hasOverrides: Bool = false) -> String {
        format(DueDateSummary(dueDate, lockDate: lockDate, hasOverrides: hasOverrides), addDuePrefix: true)
    }

    public static func formatWithoutPrefix(_ dueDate: Date?, lockDate: Date? = nil, hasOverrides: Bool = false) -> String {
        format(DueDateSummary(dueDate, lockDate: lockDate, hasOverrides: hasOverrides), addDuePrefix: false)
    }

    public static func format(_ dueDateSummary: DueDateSummary, addDuePrefix: Bool = true) -> String {
        switch dueDateSummary {
        case .noDueDate:
            return noDueDateText
        case .dueDate(let date):
            return addDuePrefix ? dateText(date) : dateTextWithoutDue(date)
        case .availabilityClosed:
            return availabilityClosedText
        case .multipleDueDates:
            return multipleDueDatesText
        }
    }

    // MARK: - Formatted texts

    public static func dateText(_ date: Date) -> String {
        return String.localizedStringWithFormat(
            String(localized: "Due %@", bundle: .core, comment: "i.e. Due <Jan 10, 2020 at 9:00 PM>"),
            date.relativeDateTimeString
        )
    }

    public static func dateTextWithoutDue(_ date: Date) -> String {
        date.relativeDateTimeString
    }

    public static let noDueDateText: String = String(localized: "No Due Date", bundle: .core)

    public static let availabilityClosedText: String = String(localized: "Closed For Submission", bundle: .core)

    public static let multipleDueDatesText: String = String(localized: "Multiple Due Dates", bundle: .core)
}
