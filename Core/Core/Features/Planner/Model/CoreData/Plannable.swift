//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public enum PlannableType: String, Codable {
    case announcement, assignment, discussion_topic, quiz, wiki_page, planner_note, calendar_event, assessment_request
    case sub_assignment
    case other
}

public final class Plannable: NSManagedObject {
    public typealias JSON = APIPlannable

    @NSManaged public var id: String
    @NSManaged public var typeRaw: String
    @NSManaged public var title: String?
    @NSManaged public var htmlURL: URL?
    @NSManaged public var canvasContextIDRaw: String?
    @NSManaged public var contextName: String?
    @NSManaged public var date: Date?
    @NSManaged public var pointsPossibleRaw: NSNumber?
    @NSManaged public var userID: String?
    @NSManaged public var details: String?
    @NSManaged public var isMarkedComplete: Bool
    @NSManaged public var isSubmitted: Bool
    @NSManaged private var discussionCheckpointStepRaw: DiscussionCheckpointStepWrapper?
    public var discussionCheckpointStep: DiscussionCheckpointStep? {
        get { return discussionCheckpointStepRaw?.value } set { discussionCheckpointStepRaw = .init(value: newValue) }
    }

    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var plannableType: PlannableType {
        get { return PlannableType(rawValue: typeRaw) ?? PlannableType.other }
        set { typeRaw = newValue.rawValue }
    }

    public var context: Context? {
        get { return Context(canvasContextID: canvasContextIDRaw ?? "") }
        set { canvasContextIDRaw = newValue?.canvasContextID }
    }

    // Evaluates only the state of the item, not the correct date range (currently 28 days).
    public var shouldShowInTodoList: Bool {
        plannableType != .announcement && plannableType != .assessment_request && !isMarkedComplete && !isSubmitted
    }

    @discardableResult
    public static func save(_ item: APIPlannable, userId: String?, in client: NSManagedObjectContext) -> Plannable {
        let model: Plannable = client.first(where: #keyPath(Plannable.id), equals: item.plannable_id.value) ?? client.insert()
        model.id = item.plannable_id.value
        model.plannableType = item.plannableType
        model.htmlURL = item.html_url?.rawValue
        model.contextName = item.context_name
        model.title = item.plannable?.title
        model.date = item.plannable_date
        model.pointsPossible = item.plannable?.points_possible
        model.details = item.plannable?.details
        model.context = item.context
        model.userID = userId
        model.discussionCheckpointStep = .init(
            tag: item.plannable?.sub_assignment_tag,
            requiredReplyCount: item.details?.reply_to_entry_required_count
        )
        model.isMarkedComplete = item.planner_override?.marked_complete ?? false
        model.isSubmitted = item.submissions?.value1?.submitted ?? false
        return model
    }

    @discardableResult
    public static func save(_ item: APIPlannerNote, contextName: String?, in client: NSManagedObjectContext) -> Plannable {
        let model: Plannable = client.first(where: #keyPath(Plannable.id), equals: item.id) ?? client.insert()
        model.id = item.id
        model.plannableType = .planner_note
        model.htmlURL = nil
        model.contextName = contextName
        model.title = item.title
        model.date = item.todo_date
        model.pointsPossible = nil
        model.details = item.details
        model.context = Context(.course, id: item.course_id) ?? Context(.user, id: item.user_id)
        model.userID = item.user_id
        model.isMarkedComplete = false
        model.isSubmitted = false
        return model
    }

    @discardableResult
    public static func save(_ item: APICalendarEvent, userId: String?, in client: NSManagedObjectContext) -> Plannable {
        let model: Plannable = client.first(where: #keyPath(Plannable.id), equals: item.id.value) ?? client.insert()
        model.id = item.id.value
        model.plannableType = .init(rawValue: item.type.rawValue) ?? .other
        model.title = item.title
        model.htmlURL = item.html_url
        model.context = Context(canvasContextID: item.context_code)
        model.contextName = item.context_name
        model.date = item.start_at
        model.pointsPossible = item.assignment?.points_possible
        model.details = item.description
        model.userID = userId
        model.isMarkedComplete = false
        model.isSubmitted = false
        return model
    }
}

extension Plannable {
    public var icon: UIImage {
        switch plannableType {
        case .assignment:
            .assignmentLine
        case .quiz:
            .quizLine
        case .discussion_topic:
            .discussionLine
        case .sub_assignment:
            discussionCheckpointStep != nil ? .discussionLine : .assignmentLine
        case .announcement:
            .announcementLine
        case .wiki_page:
            .documentLine
        case .planner_note:
            .noteLine
        case .calendar_event:
            .calendarMonthLine
        case .assessment_request:
            .peerReviewLine
        case .other:
            .warningLine
        }
    }

    public var color: UIColor {
        guard let canvasContextID = canvasContextIDRaw else { return .textDark }

        if AppEnvironment.shared.k5.isK5Enabled,
           let context = Context(canvasContextID: canvasContextID),
           context.contextType == .course {
            if let course: Course = managedObjectContext?.first(where: #keyPath(Course.id), equals: context.id) {
                return course.color
            } else {
                return .textDarkest
            }
        } else {
            if let color: ContextColor = managedObjectContext?.first(where: #keyPath(ContextColor.canvasContextID), equals: canvasContextID) {
                return color.color
            } else {
                return .textDark
            }
        }
    }

    /// Suffixes the API returned `contextName` with "To Do" if the plannable is a ToDo.
    public var contextNameUserFacing: String? {
        if plannableType != .planner_note {
            return contextName
        }

        if let contextName {
            return String(localized: "\(contextName) To Do", bundle: .core, comment: "<CourseName> To Do")
        } else {
            return String(localized: "To Do", bundle: .core)
        }
    }
}
