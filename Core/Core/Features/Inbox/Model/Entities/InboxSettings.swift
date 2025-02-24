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

final public class InboxSettings: NSManagedObject, WriteableModel {

    @NSManaged public var id: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var outOfOfficeLastDate: Date?
    @NSManaged public var outOfOfficeMessage: String?
    @NSManaged public var outOfOfficeSubject: String?
    @NSManaged public var outOfOfficeFirstDate: Date?
    @NSManaged public var signature: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var useOutOfOffice: Bool
    @NSManaged public var useSignature:  Bool
    @NSManaged public var userId: String?

    @discardableResult
    public static func save(_ item: APIInboxSettings, in context: NSManagedObjectContext) -> InboxSettings {
        let dbEntity: InboxSettings = context.first(where: #keyPath(InboxSettings.userId), equals: item.data.userId) ?? context.insert()
        dbEntity.id = item.data._id ?? ""
        dbEntity.createdAt = item.data.createdAt
        dbEntity.outOfOfficeLastDate = item.data.outOfOfficeLastDate
        dbEntity.outOfOfficeMessage = item.data.outOfOfficeMessage
        dbEntity.outOfOfficeSubject = item.data.outOfOfficeSubject
        dbEntity.outOfOfficeFirstDate = item.data.outOfOfficeFirstDate
        dbEntity.signature = item.data.signature
        dbEntity.updatedAt = item.data.updatedAt
        dbEntity.useOutOfOffice = item.data.useOutOfOffice ?? false
        dbEntity.useSignature = item.data.useSignature ?? false
        dbEntity.userId = item.data.userId

        return dbEntity
    }
}
