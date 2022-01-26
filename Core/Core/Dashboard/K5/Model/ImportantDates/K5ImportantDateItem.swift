//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class K5ImportantDate {
    public var title: String {
        return date.weekdayName + ", " + date.dayInMonth
    }
    public let date: Date
    public private(set) var events: Set<K5ImportantDateItem>

    public func addEvent(_ event: CalendarEvent, color: Color) {
        events.insert(importantDateItem(from: event, color: color))
    }

    private func importantDateItem(from event: CalendarEvent, color: Color) -> K5ImportantDateItem {
        return K5ImportantDateItem(subject: event.contextName, title: event.title, color: color, date: event.startAt, route: event.htmlURL, type: event.type)
    }

    init(with event: CalendarEvent, color: Color) {
        self.date = event.startAt ?? Date()
        let dateEvent = K5ImportantDateItem(subject: event.contextName, title: event.title, color: color, date: event.startAt, route: event.htmlURL, type: event.type)
        events = [dateEvent]
    }
}

extension K5ImportantDate: Hashable {
    public static func == (lhs: K5ImportantDate, rhs: K5ImportantDate) -> Bool {
        return lhs.title == rhs.title
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

public struct K5ImportantDateItem {

    public let subject: String
    public let title: String
    public let color: Color
    public let date: Date?
    public let route: URL?
    public let type: CalendarEventType
    public var iconImage: Image {
        switch type {
        case .event:
            return Image.announcementLine
        case .assignment:
            return Image.assignmentLine
        }
    }

    internal init(subject: String?, title: String, color: Color, date: Date?, route: URL?, type: CalendarEventType) {
        self.subject = subject ?? ""
        self.title = title
        self.color = color
        self.date = date
        self.route = route
        self.type = type
    }
}

extension K5ImportantDateItem: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
