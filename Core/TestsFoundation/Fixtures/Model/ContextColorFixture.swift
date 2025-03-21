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

import CoreData
@testable import Core
import UIKit

extension ContextColor {
    @discardableResult
    public static func make(
        canvasContextID: String = "course_1",
        color: UIColor = .red,
        in context: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> ContextColor {
        let savedColors = ContextColor.save(APICustomColors(custom_colors: [canvasContextID: color.hexString]), in: context)
        try! context.save()
        return savedColors.first!
    }
}
