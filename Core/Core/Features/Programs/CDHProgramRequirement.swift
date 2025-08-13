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

final public class CDHProgramRequirement: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var isCompletionRequired: Bool
    @NSManaged public var dependency: CDHProgramDependency?
    @NSManaged public var dependent: CDHProgramDependent?

    @discardableResult
    static func save(
        _ item: GetHProgramsResponse.Requirement,
        in context: NSManagedObjectContext
    ) -> CDHProgramRequirement {
        let dbEntity: CDHProgramRequirement = context.first(
            where: #keyPath(CDHProgramRequirement.id),
            equals: item.id
        ) ?? context.insert()

        dbEntity.id = item.id ?? ""
        dbEntity.isCompletionRequired = item.isCompletionRequired ?? false
        if let dependency = item.dependency {
            dbEntity.dependency = CDHProgramDependency.save(dependency, in: context)
        } else {
            dbEntity.dependency = nil
        }

        if let dependent = item.dependent {
            dbEntity.dependent = CDHProgramDependent.save(dependent, in: context)
        } else {
            dbEntity.dependent = nil
        }
        return dbEntity
    }
}

