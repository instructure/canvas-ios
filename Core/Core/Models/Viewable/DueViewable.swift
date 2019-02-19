//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public protocol DueViewable {
    var dueAt: Date? { get }
}

extension DueViewable {
    public var dueText: String {
        guard let dueAt = self.dueAt else {
            return NSLocalizedString("No Due Date", bundle: .core, comment: "")
        }
        return DateFormatter.localizedString(from: dueAt, dateStyle: .medium, timeStyle: .short)
    }

    public var assignmentDueByText: String {
        guard let dueAt = self.dueAt else {
            return NSLocalizedString("No Due Date", bundle: .core, comment: "")
        }
        let format = dueAt > Clock.now
            ? NSLocalizedString("This assignment is due by %@", bundle: .core, comment: "")
            : NSLocalizedString("This assignment was due by %@", bundle: .core, comment: "")

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        let dateText = formatter.string(from: dueAt)
        return String.localizedStringWithFormat(format, dateText)
    }
}
