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

/// Due date labels can display more kinds of texts besides the actual due date.
/// These are the summarized cases based on due date, lock date, overrides.
public enum DueDateSummary: Equatable {
    case noDueDate
    case dueDate(Date)
    case availabilityClosed
    case multipleDueDates

    public init(_ dueDate: Date?, lockDate: Date? = nil, hasOverrides: Bool = false) {
        if let lockDate, Clock.now > lockDate {
            self = .availabilityClosed
        } else if hasOverrides {
            self = .multipleDueDates
        } else if let dueDate {
            self = .dueDate(dueDate)
        } else {
            self = .noDueDate
        }
    }

    public var text: String {
        DueDateFormatter.format(self, addDuePrefix: true)
    }

    public var textWithoutPrefix: String {
        DueDateFormatter.format(self, addDuePrefix: false)
    }
}

extension Array<DueDateSummary> {

    /// Returns multiple due dates when all cases are regular due dates,
    /// or a single special case when any element matches that special case.
    public func reduceIfNeeded() -> [DueDateSummary] {
        if contains(.availabilityClosed) {
            [.availabilityClosed]
        } else if contains(.multipleDueDates) {
            [.multipleDueDates]
        } else {
            self
        }
    }
}
