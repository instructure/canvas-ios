//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public final class CDContextColor: NSManagedObject {
    @NSManaged public var canvasContextID: String
    /// This is the color assigned by the teacher to elementary courses. Nil for non-elementary courses and for other context types (groups, users).
    @NSManaged public var elementaryCourseColorHex: String?
    /// This is the custom color of the context that the user can change. A color is always assigned by the API to a context.
    @NSManaged public var contextColorHex: String

    @discardableResult
    public static func save(
        _ responses: GetCDContextColorsUseCase.APIResponses,
        in context: NSManagedObjectContext
    ) -> [CDContextColor] {
        // TODO also save group/user colors
        responses.courses.compactMap { apiCourse in
            let contextID = apiCourse.context.canvasContextID
            let courseColorHex = apiCourse.course_color
            let contextColorHex = responses.customColors.custom_colors[contextID]

            guard let contextColorHex else {
                return nil
            }

            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CDContextColor.canvasContextID),
                contextID
            )
            let model: CDContextColor = context.fetch(predicate).first ?? context.insert()
            model.canvasContextID = contextID
            model.elementaryCourseColorHex = courseColorHex
            model.contextColorHex = contextColorHex
            return model
        }
    }
}
