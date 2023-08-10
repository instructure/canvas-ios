//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public enum EnvironmentFeatureFlags: String {
    case send_usage_metrics
    case mobile_offline_mode
}

public class GetEnvironmentFeatureFlags: CollectionUseCase {
    public typealias Model = FeatureFlag
    public let context: Context

    public var scope: Scope {
        let contextPredicate = NSPredicate(format: "%K == %@", #keyPath(FeatureFlag.canvasContextID), self.context.canvasContextID)
        let environmentFlagPredicate = NSPredicate(format: "%K == true", #keyPath(FeatureFlag.isEnvironmentFlag))
        let predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                contextPredicate,
                environmentFlagPredicate,
            ]
        )
        return Scope(predicate: predicate, order: [NSSortDescriptor(key: #keyPath(FeatureFlag.name), ascending: true)])
    }

    public var cacheKey: String? {
        "\(context.canvasContextID)-features-environment-json"
    }

    public var request: GetEnvironmentFeatureFlagsRequest {
        GetEnvironmentFeatureFlagsRequest(context: context)
    }

    public init(context: Context) {
        self.context = context
    }

    public func write(response: [String: Bool]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for (key, isEnabled) in response {
            let apiFeatureFlag = APIFeatureFlag(
                key: key,
                isEnabled: isEnabled,
                canvasContextID: context.canvasContextID,
                isEnvironmentFlag: true
            )
            FeatureFlag.save(apiFeatureFlag, in: client)
        }
    }
}

extension Store where U == GetEnvironmentFeatureFlags {
    public func isFeatureEnabled(_ featureFlag: EnvironmentFeatureFlags) -> Bool {
        let featureFlagToFind = all
            .filter { $0.name == featureFlag.rawValue}
            .first

        return featureFlagToFind?.enabled ?? false
    }
}
