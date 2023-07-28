//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/bookmarks.html#method.bookmarks/bookmarks.index
public struct APIBookmark: Codable, Equatable {
    public let id: ID?
    public let name: String?
    public let url: String?
    public let position: Int?
    public let data: String?
    public var contextName: String? {
        guard let stringData = data,
              let data = stringData.data(using: .utf8)
        else { return nil }

        let contextNameContainer = try? decoder.decode(APIBookmarkContextName.self,
                                                       from: data)
        return contextNameContainer?.contextName
    }

    public init(id: String? = nil,
                name: String? = nil,
                url: String? = nil,
                position: Int? = nil,
                data: String? = nil) {
        self.id = ID(id)
        self.name = name
        self.url = url
        self.position = position
        self.data = data
    }

    public init(name: String,
                url: String,
                contextName: String?) {
        self.id = nil
        self.name = name
        self.url = url
        self.position = nil
        self.data = {
            guard let contextName else { return nil }
            let container = APIBookmarkContextName(contextName: contextName)
            guard let jsonData = try? encoder.encode(container) else { return nil }
            return String(data: jsonData, encoding: .utf8)
        }()
    }
}

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

struct APIBookmarkContextName: Codable {
    let contextName: String
}
