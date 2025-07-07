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

import CoreData
import Foundation

public class GetModule: APIUseCase {
    public typealias Model = Module

    public var request: GetModuleRequest {
        .init(courseID: courseID, moduleID: moduleID)
    }

    public var cacheKey: String? {
        "GetModule-\(courseID)-\(moduleID)"
    }

    // MARK: - Dependencies

    public let courseID: String
    public let moduleID: String
    public let includes: [GetModulesRequest.Include]

    public init(
        courseID: String,
        moduleID: String,
        includes: [GetModulesRequest.Include] = []
    ) {
        self.courseID = courseID
        self.moduleID = moduleID
        self.includes = includes
    }

    public func write(
        response: APIModule?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response = response else { return }
        Module.save(response, forCourse: courseID, updateModuleItems: false, in: client)
    }
}
