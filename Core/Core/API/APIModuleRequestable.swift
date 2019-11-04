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

// https://canvas.instructure.com/doc/api/modules.html#method.context_modules_api.index
public struct GetModulesRequest: APIRequestable {
    public typealias Response = [APIModule]

    public let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/modules"
    }

    public var query: [APIQueryItem] {
        return [
            .include([ "items", "content_details" ]),
        ]
    }
}

public struct GetModuleItemsRequest: APIRequestable {
    public typealias Response = [APIModuleItem]

    public let courseID: String
    public let moduleID: String

    public init(courseID: String, moduleID: String) {
        self.courseID = courseID
        self.moduleID = moduleID
    }

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items"
    }

    public var query: [APIQueryItem] {
        return [
            .include(["content_details"]),
        ]
    }
}
