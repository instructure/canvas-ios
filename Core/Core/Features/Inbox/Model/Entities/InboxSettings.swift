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
        let data = item.data.myInboxSettings
        let dbEntity: InboxSettings = context.first(where: #keyPath(InboxSettings.userId), equals: data.userId) ?? context.insert()
        print(item)
        dbEntity.id = data._id ?? ""
        dbEntity.createdAt = data.createdAt
        dbEntity.outOfOfficeLastDate = data.outOfOfficeLastDate
        dbEntity.outOfOfficeMessage = data.outOfOfficeMessage
        dbEntity.outOfOfficeSubject = data.outOfOfficeSubject
        dbEntity.outOfOfficeFirstDate = data.outOfOfficeFirstDate
        dbEntity.signature = data.signature
        dbEntity.updatedAt = data.updatedAt
        dbEntity.useOutOfOffice = data.useOutOfOffice ?? false
        dbEntity.useSignature = data.useSignature ?? false
        dbEntity.userId = data.userId

        return dbEntity
    }
}
