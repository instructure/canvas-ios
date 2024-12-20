//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public enum AccountNotificationIcon: String, Codable {
    case calendar, error, information, question, warning
}

final public class AccountNotification: NSManagedObject, WriteableModel {
    @NSManaged public var endAt: Date?
    @NSManaged var iconRaw: String
    @NSManaged public var id: String
    @NSManaged public var message: String
    @NSManaged public var startAt: Date?
    @NSManaged public var subject: String

    public var icon: AccountNotificationIcon {
        get { AccountNotificationIcon(rawValue: iconRaw) ?? .information }
        set { iconRaw = newValue.rawValue }
    }

    @discardableResult
    public static func save(_ item: APIAccountNotification, in context: NSManagedObjectContext) -> AccountNotification {
        let model: AccountNotification = context.first(where: #keyPath(AccountNotification.id), equals: item.id.value) ?? context.insert()
        model.endAt = item.end_at
        model.icon = item.icon
        model.id = item.id.value
        model.message = item.message
        model.startAt = item.start_at
        model.subject = item.subject
        return model
    }
}
