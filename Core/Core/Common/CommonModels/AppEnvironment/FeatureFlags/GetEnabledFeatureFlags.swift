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

public class GetEnabledFeatureFlags: CollectionUseCase {
    public typealias Model = FeatureFlag
    public let context: Context

    public var scope: Scope {
        let contextPredicate = NSPredicate(format: "%K == %@", #keyPath(FeatureFlag.canvasContextID), self.context.canvasContextID)
        let enabledPredicate = NSPredicate(format: "%K == true", #keyPath(FeatureFlag.enabled))
        let environmentFlagPredicate = NSPredicate(format: "%K == false", #keyPath(FeatureFlag.isEnvironmentFlag))
        let predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                contextPredicate,
                enabledPredicate,
                environmentFlagPredicate
            ]
        )
        return Scope(predicate: predicate, order: [NSSortDescriptor(key: #keyPath(FeatureFlag.name), ascending: true)])
    }

    public var cacheKey: String? {
        return "\(context.canvasContextID)-enabled-feature-flags"
    }

    public var request: GetEnabledFeatureFlagsRequest {
        return GetEnabledFeatureFlagsRequest(context: context)
    }

    public init(context: Context) {
        self.context = context
    }

    public func write(response: [String]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for key in response {
            let apiFeatureFlag = APIFeatureFlag(
                key: key,
                isEnabled: true,
                canvasContextID: context.canvasContextID,
                isEnvironmentFlag: false
            )
            FeatureFlag.save(apiFeatureFlag, in: client)
        }
    }
}

extension Store where U == GetEnabledFeatureFlags {
    public func isFeatureFlagEnabled(_ key: APIFeatureFlag.Key) -> Bool {
        all.isFeatureFlagEnabled(key)
    }
}
