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

import CoreData
import Foundation

public class GetModules: APIUseCase {
    public typealias Model = Module

    public let courseID: String

    public var scope: Scope {
        let position = NSSortDescriptor(key: #keyPath(Module.position), ascending: true)
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Module.courseID), courseID)
        return Scope(predicate: predicate, order: [position], sectionNameKeyPath: nil)
    }

    public var cacheKey: String? {
        return "get-modules-\(courseID)"
    }

    public var request: GetModulesRequest {
        return GetModulesRequest(courseID: courseID)
    }

    public init(courseID: String) {
        self.courseID = courseID
    }

    public func write(response: [APIModule]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        Module.save(response, forCourse: courseID, in: client)
    }
}
