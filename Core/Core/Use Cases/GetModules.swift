//
// Copyright (C) 2019-present Instructure, Inc.
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

public struct GetModules: APIUseCase {
    public typealias Model = Module

    public let courseID: String

    public var scope: Scope {
        return .where(#keyPath(Module.courseID), equals: courseID, orderBy: #keyPath(Module.position))
    }

    public var cacheKey: String {
        return "get-modules-\(courseID)"
    }

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var request: GetModulesRequest {
        return GetModulesRequest(courseID: courseID)
    }

    public func write(response: [APIModule]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let response = response else { return }
        Module.save(response, forCourse: courseID, in: client)
    }
}
