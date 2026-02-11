//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Foundation

struct GlobalAnnouncementsWidgetItem: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: AccountNotificationIcon
    let startDate: Date?
    let isClosed: Bool
}

#if DEBUG

extension GlobalAnnouncementsWidgetItem {
    static func make(
        id: String = "",
        title: String = "",
        icon: AccountNotificationIcon = .information,
        startDate: Date? = nil,
        isClosed: Bool = false
    ) -> GlobalAnnouncementsWidgetItem {
        GlobalAnnouncementsWidgetItem(
            id: id,
            title: title,
            icon: icon,
            startDate: startDate,
            isClosed: isClosed
        )
    }
}

#endif
