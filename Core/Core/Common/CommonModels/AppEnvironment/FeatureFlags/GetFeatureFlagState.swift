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

import Foundation
import CoreData

public class GetFeatureFlagState: APIUseCase {
    public typealias Model = FeatureFlag

    public let featureName: FeatureFlagName
    public let context: Context

    public var scope: Scope {
        let contextPredicate = NSPredicate(format: "%K == %@", #keyPath(FeatureFlag.canvasContextID), context.canvasContextID)
        let namePredicate = NSPredicate(format: "%K == %@", #keyPath(FeatureFlag.name), featureName.rawValue)
        let predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                contextPredicate,
                namePredicate
            ]
        )
        return Scope(predicate: predicate, order: [NSSortDescriptor(key: #keyPath(FeatureFlag.name), ascending: true)])
    }

    public var cacheKey: String? {
        return "get-\(context.canvasContextID)-\(featureName.rawValue)-feature-flag-state"
    }

    public var request: GetFeatureFlagStateRequest {
        return GetFeatureFlagStateRequest(featureName: featureName, context: context)
    }

    public init(featureName: FeatureFlagName, context: Context) {
        self.featureName = featureName
        self.context = context
    }

    public func write(response: APIFeatureFlagState?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        FeatureFlag.save(response, in: client)
    }
}
