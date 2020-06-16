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
@testable import Core

extension FeatureFlag {
    @discardableResult
    public static func make(
        context: Context = Context(.course, id: "1"),
        name: String = "feature_flag",
        enabled: Bool = true,
        in managedContext: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> FeatureFlag {
        let model: FeatureFlag = managedContext.insert()
        model.context = context
        model.name = name
        model.enabled = enabled
        return model
    }
}
