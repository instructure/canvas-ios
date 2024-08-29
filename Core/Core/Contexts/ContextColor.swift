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
    /// This is the color assigned by the teacher to elementary courses.
    /// Nil in case the context is a user or a group since they have no default/teacher assigned colors.
    @NSManaged public var courseColorHex: String?
    /// This is the custom color that the user can assign to the context.
    @NSManaged public var contextColorHex: String?

    @discardableResult
    public static func save(
        _ responses: GetContextColorsUseCase.APIResponses,
        in context: NSManagedObjectContext
    ) -> [CDContextColor] {
        // TODO also save group/user colors
        responses.courses.compactMap { apiCourse in
            let contextID = apiCourse.context.canvasContextID
            let courseColorHex = apiCourse.course_color
            let contextColorHex = responses.customColors.custom_colors[contextID]

            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CDContextColor.canvasContextID),
                contextID
            )
            let model: CDContextColor = context.fetch(predicate).first ?? context.insert()
            model.canvasContextID = contextID
            model.courseColorHex = courseColorHex
            model.contextColorHex = contextColorHex
            return model
        }
    }
}
