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

import UserNotifications

extension UNTimeIntervalNotificationTrigger {

    convenience init?(assignmentDueDate: Date, beforeTime: DateComponents, currentDate: Date = .now) {
        guard let beforeTimeInterval = Calendar.current.date(byAdding: beforeTime, to: assignmentDueDate)?.timeIntervalSince(assignmentDueDate) else {
            return nil
        }

        let triggerDate = {
            var triggerDate = assignmentDueDate
            triggerDate.addTimeInterval(-beforeTimeInterval)
            return triggerDate
        }()

        let timeUntilTrigger = triggerDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970
        self.init(timeInterval: timeUntilTrigger, repeats: false)
    }
}
