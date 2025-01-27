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
import Foundation

public final class QuizSubmissionUser: NSManagedObject, WriteableModel {
    public typealias JSON = APIUser

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var sortableName: String
    @NSManaged public var avatarURL: URL?
    @NSManaged public var courseID: String?
    @NSManaged public var pronouns: String?

    @discardableResult
    public static func save(_ apiEntity: APIUser, in context: NSManagedObjectContext) -> QuizSubmissionUser {
        let dbEntity: QuizSubmissionUser = context.first(where:
                #keyPath(QuizSubmissionUser.id), equals: apiEntity.id.value) ?? context.insert()

        dbEntity.id = apiEntity.id.value
        dbEntity.name = apiEntity.name
        dbEntity.sortableName = apiEntity.sortable_name
        dbEntity.avatarURL = apiEntity.avatar_url?.rawValue
        dbEntity.pronouns = apiEntity.pronouns
        return dbEntity
    }
}

#if DEBUG

public extension QuizSubmissionUser {
    static func make(id: String = "0", in context: NSManagedObjectContext)
    -> QuizSubmissionUser {
        let apiUser = APIUser.make(id: ID(id))
        return QuizSubmissionUser.save(apiUser, in: context)
    }
}

#endif
