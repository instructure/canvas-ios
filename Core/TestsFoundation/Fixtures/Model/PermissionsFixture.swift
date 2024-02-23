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

import CoreData
import Foundation
@testable import Core

extension Permissions {
    @discardableResult
    public static func make(
        from api: APIPermissions = .make(),
        for context: Context = Context(.account, id: "1"),
        in db: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> Permissions {
        let model = Permissions.save(api, for: context, in: db)
        try! db.save()
        return model
    }
}
