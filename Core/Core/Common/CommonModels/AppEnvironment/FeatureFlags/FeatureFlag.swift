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

public struct APIFeatureFlag {
    public enum Key: String {
        case assignmentEnhancements = "assignments_2_student"
    }
    public let key: String
    public let isEnabled: Bool
    public let canvasContextID: String
    public let isEnvironmentFlag: Bool
}

public final class FeatureFlag: NSManagedObject, WriteableModel {
    public typealias JSON = APIFeatureFlag

    @NSManaged public private(set) var canvasContextID: String?
    @NSManaged public var name: String
    @NSManaged public var enabled: Bool
    @NSManaged public var isEnvironmentFlag: Bool

    public var context: Context? {
        get { return canvasContextID.flatMap { Context(canvasContextID: $0) } }
        set { canvasContextID = newValue?.canvasContextID }
    }

    @discardableResult
    public static func save(_ item: APIFeatureFlag, in context: NSManagedObjectContext) -> FeatureFlag {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(FeatureFlag.canvasContextID), item.canvasContextID),
            NSPredicate(format: "%K == %@", #keyPath(FeatureFlag.name), item.key)
        ])
        let flag: FeatureFlag = context.fetch(predicate).first ?? context.insert()
        flag.name = item.key
        flag.enabled = item.isEnabled
        flag.canvasContextID = item.canvasContextID
        flag.isEnvironmentFlag = item.isEnvironmentFlag
        return flag
    }
}

extension Collection where Element == FeatureFlag {
    public func isFeatureFlagEnabled(_ key: APIFeatureFlag.Key) -> Bool {
        isFeatureFlagEnabled(name: key.rawValue)
    }

    public func isFeatureEnabled(_ featureFlag: EnvironmentFeatureFlags) -> Bool {
        isFeatureFlagEnabled(name: featureFlag.rawValue)
    }

    private func isFeatureFlagEnabled(name: String) -> Bool {
        contains { flag in
            flag.name == name && flag.enabled
        }
    }
}
