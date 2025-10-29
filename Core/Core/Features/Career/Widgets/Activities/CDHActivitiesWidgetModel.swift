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

import CoreData

public final class CDHActivitiesWidgetModel: NSManagedObject {
    @NSManaged public var courseID: String
    @NSManaged public var courseName: String
    @NSManaged public var moduleCountCompleted: NSNumber

    @discardableResult
    public static func save(
        _ apiEntity: GetHActivitiesWidgetResponse.Widget,
        in context: NSManagedObjectContext
    ) -> CDHActivitiesWidgetModel {
        let dbEntity: CDHActivitiesWidgetModel = context.first(
            where: #keyPath(CDHActivitiesWidgetModel.courseID),
            equals: apiEntity.courseID
        ) ?? context.insert()

        dbEntity.courseID = String(apiEntity.courseID.defaultToZero)
        dbEntity.courseName = apiEntity.courseName.defaultToEmpty
        dbEntity.moduleCountCompleted = NSNumber(value: apiEntity.moduleCountCompleted.defaultToZero)
        return dbEntity
    }
}
