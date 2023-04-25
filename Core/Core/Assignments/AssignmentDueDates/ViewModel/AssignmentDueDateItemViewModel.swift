//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import SwiftUI

public struct AssignmentDueDateItemViewModel: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let assignee: String
    public private(set) var from: String = "--"
    public private(set) var fromEmptyAccessibility: String?
    public private(set) var until: String = "--"
    public private(set) var untilEmptyAccessibility: String?

    public init(item: AssignmentDate) {
        self.id = item.id

        if let dueAt = item.dueAt {
            let format = NSLocalizedString("Due %@", bundle: .core, comment: "i.e. Due <Jan 10, 2020 at 9:00 PM>")
            self.title = String.localizedStringWithFormat(format, dueAt.dateTimeString)
        } else {
            self.title = NSLocalizedString("No Due Date", bundle: .core, comment: "")
        }

        self.assignee = item.title ?? NSLocalizedString("Everyone", comment: "")

        if let unlockAt = item.unlockAt?.dateTimeString {
            self.from = unlockAt
        } else {
            self.fromEmptyAccessibility = NSLocalizedString("No available from date set.", bundle: .core, comment: "")
        }

        if let lockAt = item.lockAt?.dateTimeString {
            self.until = lockAt
        } else {
            self.untilEmptyAccessibility = NSLocalizedString("No available until date set.", bundle: .core, comment: "")
        }
    }
}
