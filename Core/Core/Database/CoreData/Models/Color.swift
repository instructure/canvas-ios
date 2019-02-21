//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData
import UIKit

public final class Color: NSManagedObject {
    @NSManaged public var canvasContextID: String
    @NSManaged public var color: UIColor

    @discardableResult
    public static func save(_ item: APICustomColors, in context: PersistenceClient) -> [Color] {
        return item.custom_colors.compactMap { record in
            guard let color = UIColor(hexString: record.value) else { return nil }
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Color.canvasContextID), record.key)
            let model: Color = context.fetch(predicate).first ?? context.insert()
            model.canvasContextID = record.key
            model.color = color
            return model
        }
    }
}
