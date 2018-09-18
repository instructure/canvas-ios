//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public protocol AppEnvironmentDelegate {
    var environment: AppEnvironment { get }
}

public class AppEnvironment {
    public var api: API
    public let database: Persistence
    public let queue: OperationQueue
    public let router: RouterProtocol

    public init(api: API = URLSessionAPI(), database: Persistence = RealmPersistence.main, queue: OperationQueue = OperationQueue(), router: RouterProtocol) {
        self.api = api
        self.database = database
        self.queue = queue
        self.router = router
    }

    public static var shared: AppEnvironment {
        if let env = (UIApplication.shared.delegate as? AppEnvironmentDelegate)?.environment {
            return env
        }
        fatalError("UIApplication.shared.delegate must implement AppEnvironmentDelegate to use AppEnvironment.shared")
    }
}
