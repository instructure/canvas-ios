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

public final class Plannable: NSManagedObject, WriteableModel {
    public typealias JSON = APIPlannable

    @NSManaged public var id: String
    @NSManaged public var typeRaw: String
    @NSManaged public var htmlURL: URL?
    @NSManaged public var contextImage: URL?
    @NSManaged public var canvasContextIDRaw: String?

    public var context: Context? {
        get { return ContextModel(canvasContextID: canvasContextIDRaw ?? "") }
        set { canvasContextIDRaw = newValue?.canvasContextID }
    }

    @discardableResult
    public static func save(_ item: APIPlannable, in client: NSManagedObjectContext) -> Plannable {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Plannable.id), item.plannable_id.value)
        let model: Plannable = client.fetch(predicate).first ?? client.insert()
        model.id = item.plannable_id.value
        model.typeRaw = item.plannable_type
        model.htmlURL = item.html_url
        model.contextImage = item.context_image

        if let contextType = ContextType(rawValue: item.context_type.lowercased()), let courseID = item.course_id?.value {
            model.canvasContextIDRaw = ContextModel(contextType, id: courseID).canvasContextID
        }
        return model
    }

}
