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

public final class ContextColor: NSManagedObject {
    @NSManaged public var canvasContextID: String
    @NSManaged public var colorRaw: UInt32

    public var color: UIColor {
        get { return UIColor(intValue: colorRaw) }
        set { colorRaw = newValue.intValue }
    }

    @discardableResult
    public static func save(_ item: APICustomColors, in context: NSManagedObjectContext) -> [ContextColor] {
        return item.custom_colors.compactMap { record in
            guard let color = UIColor(hexString: record.value) else { return nil }
            let predicate = NSPredicate(format: "%K == %@", #keyPath(ContextColor.canvasContextID), record.key)
            let model: ContextColor = context.fetch(predicate).first ?? context.insert()
            model.canvasContextID = record.key
            model.color = color
            return model
        }
    }
}
