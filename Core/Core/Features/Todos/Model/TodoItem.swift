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

import SwiftUI

public struct TodoItem: Identifiable, Equatable {
    public let id: String
    public let type: PlannableType
    public let date: Date
    public let isAllDay: Bool

    public let title: String
    public let subtitle: String?
    public let contextName: String
    public let htmlURL: URL?

    public let color: Color
    public let icon: Image

    public init?(_ plannable: Plannable) {
        guard let date = plannable.date else { return nil }

        self.id = plannable.id
        self.type = plannable.plannableType
        self.date = date
        self.isAllDay = plannable.isAllDay

        self.title = plannable.title ?? ""
        self.subtitle = plannable.discussionCheckpointStep?.text
        self.contextName = plannable.contextNameUserFacing ?? ""
        self.htmlURL = plannable.htmlURL

        self.color = plannable.color.asColor
        self.icon = Image(uiImage: plannable.icon)
    }

    public init(
        id: String,
        type: PlannableType,
        date: Date,
        isAllDay: Bool = false,
        title: String,
        subtitle: String?,
        contextName: String,
        htmlURL: URL?,
        color: Color,
        icon: Image
    ) {

        self.id = id
        self.type = type
        self.date = date
        self.isAllDay = isAllDay

        self.title = title
        self.subtitle = subtitle
        self.contextName = contextName
        self.htmlURL = htmlURL

        self.color = color
        self.icon = icon
    }

    // MARK: Preview & Testing

    public static func make(
        id: String = "",
        type: PlannableType = .assignment,
        date: Date = Clock.now,
        isAllDay: Bool = false,
        title: String = "",
        subtitle: String? = nil,
        contextName: String = "",
        htmlURL: URL? = nil,
        color: Color = .red,
        icon: Image = .assignmentLine
    ) -> TodoItem {

        TodoItem(
            id: id,
            type: type,
            date: date,
            isAllDay: isAllDay,
            title: title,
            subtitle: subtitle,
            contextName: contextName,
            htmlURL: htmlURL,
            color: color,
            icon: icon
        )
    }
}
