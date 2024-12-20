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
    public var events: [K5ImportantDateItem] {
        return Array(uniqueEvents).sorted(by: { ($0.date, $0.subject, $0.title) < ($1.date, $1.subject, $1.title) })
    }
    private var uniqueEvents: Set<K5ImportantDateItem>

    init?(with event: CalendarEvent, color: Color) {
        guard let startDate = event.startAt else { return nil }
        self.date = startDate
        let dateEvent = K5ImportantDateItem(subject: event.contextName, title: event.title, color: color, date: startDate, route: event.htmlURL, type: event.type)
        uniqueEvents = [dateEvent]
    }

#if DEBUG
    init(with date: Date, events: Set<K5ImportantDateItem>) {
        self.date = date
        self.uniqueEvents = events
    }
#endif

    public func addEvent(_ event: CalendarEvent, color: Color) {
        guard let importantDateItem = K5ImportantDateItem(with: event, color: color) else { return }
        uniqueEvents.insert(importantDateItem)
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
    public let date: Date
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

    init(subject: String?, title: String, color: Color, date: Date, route: URL?, type: CalendarEventType) {
        self.subject = subject ?? ""
        self.title = title
        self.color = color
        self.date = date
        self.route = route
        self.type = type
    }

    init?(with event: CalendarEvent, color: Color) {
        guard let startDate = event.startAt else { return nil }
        self.init(subject: event.contextName, title: event.title, color: color, date: startDate, route: event.htmlURL, type: event.type)
    }
}

extension K5ImportantDateItem: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

extension K5ImportantDateItem: Equatable {
    public static func == (lhs: K5ImportantDateItem, rhs: K5ImportantDateItem) -> Bool {
        return lhs.subject == rhs.subject &&
        lhs.title == rhs.title &&
        lhs.date == rhs.date &&
        lhs.route == rhs.route &&
        lhs.type == rhs.type
    }
}
