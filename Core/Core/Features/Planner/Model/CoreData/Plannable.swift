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

import Foundation
import CoreData
import UIKit

public enum PlannableType: String, Codable {
    case announcement, assignment, discussion_topic, quiz, wiki_page, planner_note, calendar_event, assessment_request
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

    @discardableResult
    public static func save(_ item: PlannableItem, userID: String?, in client: NSManagedObjectContext) -> Plannable {
        let model: Plannable = client.first(where: #keyPath(Plannable.id), equals: item.plannableID) ?? client.insert()
        model.id = item.plannableID
        model.plannableType = item.plannableType
        model.htmlURL = item.htmlURL
        model.contextName = item.contextName
        model.title = item.plannableTitle
        model.date = item.date
        model.pointsPossible = item.pointsPossible
        model.details = item.details
        model.context = item.context
        model.userID = userID
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
        return model
    }
}

extension Plannable {
    func icon() -> UIImage? {
        switch(self.plannableType) {
        case .assignment:
            return UIImage.assignmentLine
        case .quiz:
            return UIImage.quizLine
        case .discussion_topic:
            return UIImage.discussionLine
        case .announcement:
            return UIImage.announcementLine
        case .wiki_page:
            return UIImage.documentLine
        case .planner_note:
            return UIImage.noteLine
        case .calendar_event:
            return UIImage.calendarMonthLine
        case .assessment_request:
            return UIImage.peerReviewLine
        case .other:
            return UIImage.warningLine
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
}
