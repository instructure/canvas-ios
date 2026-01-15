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
import Foundation

public final class CDCareerHelp: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var isBugReport: Bool
    @NSManaged public var title: String
    @NSManaged public var type: String
    @NSManaged public var url: URL?

    @discardableResult
    static func save(
        apiEntity: GetCareerHelpResponse,
        isBugReport: Bool = false,
        in context: NSManagedObjectContext
    ) -> CDCareerHelp {
        let dbEntity: CDCareerHelp = context.first(
            where: #keyPath(CDCareerHelp.title),
            equals: apiEntity.text
        ) ?? context.insert()

        dbEntity.id = apiEntity.id.defaultToEmpty
        dbEntity.isBugReport = isBugReport
        dbEntity.title = apiEntity.text.defaultToEmpty
        dbEntity.type = apiEntity.type.defaultToEmpty
        dbEntity.url = apiEntity.url
        return dbEntity
    }
}
