//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class GetEnvironmentFeatureFlags: APIUseCase {
    public typealias Model = EnvironmentFeatureFlags

    public var request: GetEnvironmentFeatureFlagsRequest { GetEnvironmentFeatureFlagsRequest() }
    public var cacheKey: String? { "environment-feature-flags" }

    public init() {}

    public func write(response: APIEnvironmentFeatureFlags?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }

        let flags: EnvironmentFeatureFlags = client.fetch().first ?? client.insert()
        flags.isCanvasForElementaryEnabled = response.canvas_for_elementary ?? false
    }
}

public extension GetEnvironmentFeatureFlags {

    class func updateAppEnvironmentFlags() {
        let env = AppEnvironment.shared
        guard let flags = env.database.viewContext.fetch().first as EnvironmentFeatureFlags? else { return }
        env.isK5Enabled = flags.isCanvasForElementaryEnabled
    }
}
