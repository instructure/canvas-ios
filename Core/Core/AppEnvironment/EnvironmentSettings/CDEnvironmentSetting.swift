//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public final class CDEnvironmentSetting: NSManagedObject, WriteableModel {
    public enum EnvironmentSettingName: String {
        case calendar_contexts_limit
    }

    public typealias JSON = (name: String, isEnabled: Bool)

    @NSManaged public var name: String
    @NSManaged public var isEnabled: Bool

    @discardableResult
    public static func save(
        _ item: (name: String, isEnabled: Bool),
        in context: NSManagedObjectContext
    ) -> CDEnvironmentSetting {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CDEnvironmentSetting.name), item.name)
        let flag: CDEnvironmentSetting = context.fetch(predicate).first ?? context.insert()
        flag.name = item.name
        flag.isEnabled = item.isEnabled
        return flag
    }
}

public extension Array where Element == CDEnvironmentSetting {

    func isEnabled(_ name: CDEnvironmentSetting.EnvironmentSettingName) -> Bool {
        contains { $0.name == name.rawValue && $0.isEnabled }
    }
}
