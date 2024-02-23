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

extension ModuleItem {
    @discardableResult
    public static func make(
        from api: APIModuleItem = .make(),
        forCourse courseID: String = "1",
        in context: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> ModuleItem {
        let model = ModuleItem.save(api, forCourse: courseID, in: context)
        try! context.save()
        return model
    }
}

extension Core.ModuleItemSequence {
    @discardableResult
    public static func make(
        from api: APIModuleItemSequence = .make(),
        courseID: String = "1",
        assetType: AssetType = .moduleItem,
        assetID: String = "1",
        in client: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> Core.ModuleItemSequence {
        let sequence: Core.ModuleItemSequence = client.insert()
        sequence.update(api, courseID: courseID, assetType: assetType, assetID: assetID, in: client)
        return sequence
    }
}
