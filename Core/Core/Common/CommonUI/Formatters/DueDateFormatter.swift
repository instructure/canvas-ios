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

public protocol DueDateFormatter {
    func format(_ dueDate: Date?) -> String
    func format(_ dueDate: Date?, lockDate: Date?) -> String

    func formatWithoutPrefix(_ dueDate: Date?, lockDate: Date?) -> String

    func format(_ dueDate: Date?, hasMultipleDueDates: Bool) -> String
    func format(_ dueDate: Date?, lockDate: Date?, hasMultipleDueDates: Bool) -> String
}

public struct DueDateFormatterLive: DueDateFormatter {

    // MARK: - Format with Due prefix

    public func format(_ dueDate: Date?) -> String {
        guard let dueDate else {
            return noDueDateText
        }

        return dateTextWithDue(dueDate)
    }

    public func format(_ dueDate: Date?, lockDate: Date?) -> String {
        availabilityText(lockDate)
            ?? format(dueDate)
    }

    // MARK: - Format without Due prefix

    private func formatWithoutPrefix(_ dueDate: Date?) -> String {
        guard let dueDate else {
            return noDueDateText
        }

        return dateTextWithoutDue(dueDate)
    }

    public func formatWithoutPrefix(_ dueDate: Date?, lockDate: Date?) -> String {
        availabilityText(lockDate)
            ?? formatWithoutPrefix(dueDate)
    }

    // MARK: - Format considering Multiple Due Dates

    public func format(_ dueDate: Date?, hasMultipleDueDates: Bool) -> String {
        multipleDueDatesText(hasMultipleDueDates)
            ?? format(dueDate)
    }

    public func format(_ dueDate: Date?, lockDate: Date?, hasMultipleDueDates: Bool) -> String {
        availabilityText(lockDate)
            ?? multipleDueDatesText(hasMultipleDueDates)
            ?? format(dueDate)
    }

    // MARK: - Formatted texts

    private func dateTextWithoutDue(_ date: Date) -> String {
        date.relativeDateTimeString
    }

    private func dateTextWithDue(_ date: Date) -> String {
        return String.localizedStringWithFormat(
            String(localized: "Due %@", bundle: .core, comment: "i.e. Due <Jan 10, 2020 at 9:00 PM>"),
            date.relativeDateTimeString
        )
    }

    private var noDueDateText: String {
        String(localized: "No Due Date", bundle: .core)
    }

    private func availabilityText(_ lockDate: Date?) -> String? {
        if let lockDate, Clock.now > lockDate {
            return String(localized: "Availability: Closed", bundle: .core)
        }

        return nil
    }

    private func multipleDueDatesText(_ hasMultipleDueDates: Bool) -> String? {
        if hasMultipleDueDates {
            return String(localized: "Multiple Due Dates", bundle: .core)
        }

        return nil
    }
}
