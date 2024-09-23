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
    @NSManaged public private(set) var canvasContextID: String
    @NSManaged public private(set) var colorRaw: UInt32

    // This is a Set because we need to allow for multiple Groups to reference
    // the same course color in the case where a student is in multiple groups in the same course.
    @NSManaged public var groups: Set<Group>
    @NSManaged public var course: Course?
    @NSManaged public var card: DashboardCard?

    public private(set) lazy var color: UIColor = calculateColor()

    @discardableResult
    public static func save(
        _ item: APICustomColors,
        in context: NSManagedObjectContext
    ) -> [ContextColor] {
        return item.custom_colors.compactMap { record in
            guard let color = UIColor(hexString: record.value) else { return nil }

            let predicate = NSPredicate(format: "%K == %@", #keyPath(ContextColor.canvasContextID), record.key)
            let model: ContextColor = context.fetch(predicate).first ?? context.insert()
            model.canvasContextID = record.key
            model.colorRaw = color.intValue

            if let canvasContext = Context(canvasContextID: record.key) {
                switch canvasContext.contextType {
                case .course:
                    if let course: Course = context.fetch(scope: .where(#keyPath(Course.id), equals: canvasContext.id)).first {
                        model.course = course
                    }
                    if let card: DashboardCard = context.fetch(scope: .where(#keyPath(DashboardCard.id), equals: canvasContext.id)).first {
                        model.card = card
                    }
                case .group:
                    if let group: Group = context.fetch(scope: .where(#keyPath(Group.id), equals: canvasContext.id)).first {
                        model.groups.insert(group)
                    }
                default:
                    break
                }
            }
            return model
        }
    }

    private func calculateColor() -> UIColor {
        let dbColor = UIColor(intValue: colorRaw)
        let colorInteractor = CourseColorsInteractorLive()
        return colorInteractor.courseColorFromAPIColor(dbColor.hexString)
    }
}
