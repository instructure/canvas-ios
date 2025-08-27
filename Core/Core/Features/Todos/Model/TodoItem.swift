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
    let plannableID: String
    let type: PlannableType
    public let date: Date

    let title: String
    let subtitle: String?
    let contextName: String
    let htmlURL: URL?

    let color: Color
    let icon: Image?

    init?(_ plannable: Plannable) {
        guard let date = plannable.date else { return nil }

        self.plannableID = plannable.id
        self.type = plannable.plannableType
        self.date = date

        self.title = plannable.title ?? ""
        self.subtitle = nil
        self.contextName = plannable.contextNameUserFacing ?? ""
        self.htmlURL = plannable.htmlURL

        self.color = plannable.color.asColor
        self.icon = plannable.icon().flatMap({ Image(uiImage: $0) })
    }

    init(
        plannableID: String,
        type: PlannableType,
        date: Date,
        title: String,
        subtitle: String?,
        contextName: String,
        htmlURL: URL?,
        color: Color,
        icon: Image?
    ) {

        self.plannableID = plannableID
        self.type = type
        self.date = date

        self.title = title
        self.subtitle = subtitle
        self.contextName = contextName
        self.htmlURL = htmlURL

        self.color = color
        self.icon = icon
    }

    public var id: String { plannableID }

    // MARK: Preview & Testing

    public static func make(
        plannableID: String = "1",
        type: PlannableType = .assignment,
        date: Date = Clock.now,
        title: String = "Example Assignment",
        subtitle: String = "Subtitle",
        contextName: String = "Example Course",
        htmlURL: URL? = nil,
        color: Color = .red,
        icon: Image? = Image.assignmentLine
    ) -> TodoItem {

        TodoItem(
            plannableID: plannableID,
            type: type,
            date: date,
            title: title,
            subtitle: subtitle,
            contextName: contextName,
            htmlURL: htmlURL,
            color: color,
            icon: icon
        )
    }
}
