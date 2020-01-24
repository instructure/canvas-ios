//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public struct APIExternalTool: Codable, Equatable {
    public let id: ID
    public let name: String
    public let domain: String?
    public let url: URL?

    public var arc: Bool {
        return domain?.contains("arc.instructure.com") == true
    }
}

public struct APIGetSessionlessLaunchResponse: Codable, Equatable {
    public let name: String?
    public let url: URL
}

public struct APIExternalToolLaunch: Codable, Equatable {
    let definition_id: ID
    let domain: String?
    let placements: [String: APIExternalToolLaunchPlacement]
}

struct APIExternalToolLaunchPlacement: Codable, Equatable {
    let title: String
    let url: URL
}

#if DEBUG
extension APIGetSessionlessLaunchResponse {
    static func make(
        name: String? = nil,
        url: URL = URL(string: "https://canvas.instructure.com")!
    ) -> APIGetSessionlessLaunchResponse {
        APIGetSessionlessLaunchResponse(name: name, url: url)
    }
}
#endif
