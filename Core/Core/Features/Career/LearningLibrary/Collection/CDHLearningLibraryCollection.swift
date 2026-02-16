//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

final public class CDHLearningLibraryCollection: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var items: Set<CDHLearningLibraryCollectionItem>

    @discardableResult
    public static func save(
        _ apiEntity: GetHLearningLibraryCollectionResponse.Collection,
        in context: NSManagedObjectContext
    ) -> CDHLearningLibraryCollection {
        let dbEntity: CDHLearningLibraryCollection = context.first(
            where: #keyPath(CDHLearningLibraryCollection.id),
            equals: apiEntity.id
        ) ?? context.insert()

        dbEntity.id = apiEntity.id
        dbEntity.name = apiEntity.name

        let collectionItems = apiEntity.items ?? []
        let dbCollectionItems = collectionItems.map { item in
            CDHLearningLibraryCollectionItem.save(
                item,
                in: context
            )
        }
        dbEntity.items = Set(dbCollectionItems)
        return dbEntity
    }
}
