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

public final class Plannable: NSManagedObject {

    public enum PlannableType: String {
        case announcement, assignment, discussion_topic, quiz, wiki_page, planner_note, calendar_event, assessment_request
        case other
    }

    public typealias JSON = APIPlannable

    @NSManaged public var id: String
    @NSManaged public var typeRaw: String
    @NSManaged public var title: String?
    @NSManaged public var htmlURL: URL?
    @NSManaged public var contextImage: URL?
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
        get { return ContextModel(canvasContextID: canvasContextIDRaw ?? "") }
        set { canvasContextIDRaw = newValue?.canvasContextID }
    }

    @discardableResult
    public static func save(_ item: APIPlannable, in client: NSManagedObjectContext, userID: String?) -> Plannable {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Plannable.id), item.plannable_id.value)
        let model: Plannable = client.fetch(predicate).first ?? client.insert()
        model.id = item.plannable_id.value
        model.typeRaw = item.plannable_type
        model.htmlURL = item.html_url?.rawValue
        model.contextImage = item.context_image
        model.contextName = item.context_name
        model.title = item.plannable?.title
        model.date = item.plannable_date
        model.pointsPossible = item.plannable?.points_possible
        model.details = item.plannable?.details
        model.userID = userID

        if let itemContextType = item.context_type, let contextType = ContextType(rawValue: itemContextType.lowercased()), let courseID = item.course_id?.value {
            model.canvasContextIDRaw = ContextModel(contextType, id: courseID).canvasContextID
        }
        return model
    }

}

extension Plannable {
    func icon() -> UIImage? {
        switch(self.plannableType) {
        case .assignment:
            return UIImage.icon(.assignment, .line)
        case .quiz:
            return UIImage.icon(.quiz, .line)
        case .discussion_topic:
            return UIImage.icon(.discussion, .line)
        case .announcement:
            return UIImage.icon(.announcement, .line)
        case .wiki_page:
            return UIImage.icon(.document, .line)
        case .planner_note:
            return UIImage.icon(.document, .line)
        case .calendar_event:
            return UIImage.icon(.calendarMonth, .line)
        case .assessment_request:
            return UIImage.icon(.peerReview, .line)
        case .other:
            return UIImage.icon(.warning, .line)
        }
    }
}
