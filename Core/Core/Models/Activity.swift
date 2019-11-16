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

import Foundation
import CoreData

public final class Activity: NSManagedObject, WriteableModel {
    public typealias JSON = APIActivity

    @NSManaged public var id: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var message: String
    @NSManaged public var title: String
    @NSManaged public var type: String
    @NSManaged public var htmlURL: URL?
    @NSManaged public var canvasContextIDRaw: String?

    public var context: Context? {
        get { return ContextModel(canvasContextID: canvasContextIDRaw ?? "") }
        set { canvasContextIDRaw = newValue?.canvasContextID }
    }

    @discardableResult
    public static func save(_ item: APIActivity, in client: NSManagedObjectContext) -> Activity {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Activity.id), "1")
        let model: Activity = client.fetch(predicate).first ?? client.insert()
        model.id = item.id.value
        model.createdAt = item.created_at
        model.message = item.message
        model.title = item.title
        model.htmlURL = item.html_url
        model.type = item.type.rawValue

        if let contextType = ContextType(rawValue: item.context_type.lowercased()) {
            var context: ContextModel?
            switch contextType {
            case .course:
                if let id = item.course_id?.value {
                    context = ContextModel(contextType, id: id)
                }
            case .group:
                if let id = item.group_id?.value {
                    context = ContextModel(contextType, id: id)
                }
            default: break
            }

            model.canvasContextIDRaw = context?.canvasContextID
        }
        return model
    }
}
