//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public final class CourseSyncSelectorCourse: NSManagedObject {
    @NSManaged public var courseId: String
    @NSManaged public var courseCode: String
    @NSManaged public var name: String
    @NSManaged public var tabs: Set<Tab>

    @discardableResult
    public static func save(_ apiEntity: APICourse,
                            app _: AppEnvironment.App? = AppEnvironment.shared.app,
                            in context: NSManagedObjectContext) -> CourseSyncSelectorCourse {
        let dbEntity: CourseSyncSelectorCourse = context.first(
            where: #keyPath(CourseSyncSelectorCourse.courseId),
            equals: apiEntity.id.value
        ) ?? context.insert()

        dbEntity.courseId = apiEntity.id.value
        dbEntity.courseCode = apiEntity.course_code ?? ""
        dbEntity.name = apiEntity.name ?? apiEntity.course_code ?? ""

        if let apiTabs = apiEntity.tabs {
            let tabs: [Tab] = apiTabs.map { apiTab in
                let urlPredicate = NSPredicate(
                    format: "%K == %@", #keyPath(Tab.htmlURL),
                    apiTab.html_url as CVarArg
                )
                let contextPredicate = NSPredicate(
                    format: "%K == %@", #keyPath(Tab.contextRaw),
                    Context.course(dbEntity.courseId).canvasContextID
                )
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [urlPredicate, contextPredicate])
                let tab: Tab = context.fetch(predicate).first ?? context.insert()
                tab.save(apiTab, in: context, context: .course(dbEntity.courseId))
                return tab
            }
            dbEntity.tabs = Set(tabs)
        } else {
            dbEntity.tabs = []
        }
        return dbEntity
    }
}
