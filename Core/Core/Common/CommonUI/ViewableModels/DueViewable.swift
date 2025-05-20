//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public protocol DueViewable {
    var dueAt: Date? { get }
}

extension DueViewable {
    public var dueText: String {
        guard let dueAt = self.dueAt else {
            return String(localized: "No Due Date", bundle: .core)
        }
        let format = String(localized: "Due %@", bundle: .core, comment: "i.e. Due <Jan 10, 2020 at 9:00 PM>")
        return String.localizedStringWithFormat(format, dueAt.relativeDateTimeString)
    }

    public var dueTextWithColon: String {
        guard let dueAt = self.dueAt else {
            return String(localized: "No Due Date", bundle: .core)
        }
        let format = String(localized: "Due: %@", bundle: .core, comment: "i.e. Due <Jan 10, 2020 at 9:00 PM>")
        return String.localizedStringWithFormat(format, dueAt.relativeDateTimeString)
    }

    public var assignmentDueByText: String {
        guard let dueAt = self.dueAt else {
            return String(localized: "No Due Date", bundle: .core)
        }
        let format = dueAt > Clock.now
            ? String(localized: "This assignment is due by %@", bundle: .core)
            : String(localized: "This assignment was due by %@", bundle: .core)

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        let dateText = formatter.string(from: dueAt)
        return String.localizedStringWithFormat(format, dateText)
    }
}
