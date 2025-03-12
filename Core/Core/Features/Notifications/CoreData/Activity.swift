//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public final class Activity: NSManagedObject, WriteableModel {
    public typealias JSON = APIActivity

    @NSManaged public var id: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var message: String?
    @NSManaged public var title: String?
    @NSManaged public var typeRaw: String
    @NSManaged public var htmlURL: URL?
    @NSManaged public var canvasContextIDRaw: String?

    public var context: Context? {
        get { return Context(canvasContextID: canvasContextIDRaw ?? "") }
        set { canvasContextIDRaw = newValue?.canvasContextID }
    }

    public var type: ActivityType {
        get { return ActivityType(rawValue: typeRaw) ?? ActivityType.submission }
        set { typeRaw = newValue.rawValue }
    }

    @discardableResult
    public static func save(_ item: APIActivity, in client: NSManagedObjectContext) -> Activity {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Activity.id), item.id.value)
        let model: Activity = client.fetch(predicate).first ?? client.insert()
        model.id = item.id.value
        model.createdAt = item.created_at
        model.message = item.message
        model.title = item.title
        model.htmlURL = item.html_url
        model.typeRaw = item.type.rawValue
        model.updatedAt = item.updated_at

        if let rawValue = item.context_type, let contextType = ContextType(rawValue: rawValue.lowercased()) {
            var context: Context?
            switch contextType {
            case .course:
                if let id = item.course_id?.value {
                    context = Context(contextType, id: id)
                }
            case .group:
                if let id = item.group_id?.value {
                    context = Context(contextType, id: id)
                }
            default: break
            }

            model.canvasContextIDRaw = context?.canvasContextID
        }
        return model
    }
}

extension Activity {
    public var icon: UIImage? {
        switch type {
        case .discussion, .discussionEntry: return .discussionLine
        case .announcement:     return .announcementLine
        case .conversation:     return .emailLine
        case .message:          return .assignmentLine
        case .submission:       return .assignmentLine
        case .conference:       return .conferences
        case .collaboration:    return .collaborations
        case .assessmentRequest: return .quizLine
        }
    }
}
