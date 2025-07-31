//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public final class CDGradingStandard: NSManagedObject {
    public typealias JSON = APIGradingStandard

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var contextType: String
    @NSManaged public var contextId: String
    @NSManaged public var pointsBased: Bool
    @NSManaged public var scalingFactor: Double
    @NSManaged public var gradingScheme: Data?

    @discardableResult
    public static func save(_ item: APIGradingStandard, in context: NSManagedObjectContext) -> CDGradingStandard {

        let predicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "%K == %@", (\CDGradingStandard.id).string, item.id.value),
            NSPredicate(format: "%K == %@", (\CDGradingStandard.contextType).string, item.context_type),
            NSPredicate(format: "%K == %@", (\CDGradingStandard.contextId).string, item.context_id.value)
        ])

        let model: CDGradingStandard = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.title = item.title
        model.contextType = item.context_type
        model.contextId = item.context_id.value
        model.pointsBased = item.points_based
        model.scalingFactor = item.scaling_factor
        model.gradingScheme = try? JSONEncoder().encode(item.grading_scheme)

        return model
    }
}
