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

import CoreData
import UIKit

public final class SyllabusSummaryItem: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var typeRaw: String
    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var htmlURL: URL?
    @NSManaged public var canvasContextIDRaw: String?
    @NSManaged public var isDiscussionCheckpointStep: Bool

    public var context: Context? {
        get { return Context(canvasContextID: canvasContextIDRaw ?? "") }
        set { canvasContextIDRaw = newValue?.canvasContextID }
    }

    public var type: SyllabusSummaryItemType {
        get { return SyllabusSummaryItemType(rawValue: typeRaw) ?? .plannable(.other) }
        set { typeRaw = newValue.rawValue }
    }

    @discardableResult
    public static func save(_ item: APIPlannable, in client: NSManagedObjectContext) -> SyllabusSummaryItem {
        let model: SyllabusSummaryItem = client.first(where: #keyPath(SyllabusSummaryItem.id), equals: item.plannable_id.value) ?? client.insert()
        model.id = item.plannable_id.value
        model.type = .plannable(item.plannableType)
        model.title = item.plannable?.title
        model.date = item.plannable_date
        model.htmlURL = item.html_url?.rawValue
        model.context = item.context
        model.isDiscussionCheckpointStep = DiscussionCheckpointStep(
            tag: item.plannable?.sub_assignment_tag,
            requiredReplyCount: item.details?.reply_to_entry_required_count
        ) != nil
        return model
    }

    @discardableResult
    public static func save(_ item: APICalendarEvent, in client: NSManagedObjectContext) -> SyllabusSummaryItem {
        let model: SyllabusSummaryItem = client.first(where: #keyPath(SyllabusSummaryItem.id), equals: item.id.value) ?? client.insert()
        model.id = item.id.value
        model.type = .calendarEvent(item.type)
        model.title = item.sub_assignment?.discussion_topic?.title ?? item.title
        model.date = item.start_at
        model.htmlURL = item.sub_assignment?.html_url ?? item.html_url
        model.context = Context(canvasContextID: item.context_code)
        model.isDiscussionCheckpointStep = DiscussionCheckpointStep(
            tag: item.sub_assignment?.sub_assignment_tag,
            requiredReplyCount: item.sub_assignment?.discussion_topic?.reply_to_entry_required_count
        ) != nil
        return model
    }
}

// MARK: - Item Type

public enum SyllabusSummaryItemType: RawRepresentable {
    case calendarEvent(CalendarEventType)
    case plannable(PlannableType)

    private static let rawPrefix: String = "syllabus-summary"
    private static let rawDelimiter: String = "|"

    public var rawValue: String {
        switch self {
        case .calendarEvent(let type):
            Self.rawPrefix + "-event" + Self.rawDelimiter + type.rawValue
        case .plannable(let type):
            Self.rawPrefix + "-plannable" + Self.rawDelimiter + type.rawValue
        }
    }

    public init?(rawValue: String) {
        let parts = rawValue.split(separator: Self.rawDelimiter).map(String.init)
        guard rawValue.hasPrefix(Self.rawPrefix), parts.count == 2 else { return nil }

        if parts[0].hasSuffix("-event"),
           let eventType = CalendarEventType(rawValue: parts[1]) {
            self = .calendarEvent(eventType)
            return
        }

        if parts[0].hasSuffix("-plannable"),
           let plannableType = PlannableType(rawValue: parts[1]) {
            self = .plannable(plannableType)
            return
        }

        return nil
    }
}

// MARK: - UI Helpers

extension SyllabusSummaryItem {

    public var icon: UIImage {
        switch type {
        case .plannable(let type) where type == .sub_assignment:
            isDiscussionCheckpointStep ? .discussionLine : type.icon
        case .plannable(let type):
            type.icon
        case .calendarEvent(let type):
            type == .assignment ? .assignmentLine : .calendarMonthLine
        }
    }

    public var dateFormatted: String? {
        guard let date else { return nil }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
}
