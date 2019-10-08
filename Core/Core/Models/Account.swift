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

public final class Account: NSManagedObject, WriteableModel {
    @NSManaged public var id: String
    @NSManaged public var name: String

    @discardableResult
    public static func save(_ item: APIAccount, in context: NSManagedObjectContext) -> Account {
        let account: Account = context.first(where: #keyPath(Account.id), equals: item.id.value) ?? context.insert()
        account.id = item.id.value
        account.name = item.name
        return account
    }
}
