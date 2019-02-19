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

public struct ContextModel: Context, Equatable, Hashable {
    public let contextType: ContextType
    public let id: String

    public static func expandTildeID(_ id: String) -> String {
        let parts: [String] = id.components(separatedBy: "~")
        if parts.count == 2, let shardID = Int64(parts[0]), let resourceID = Int64(parts[1]) {
            let shardFactor: Int64 = 10_000_000_000_000
            return (Decimal(shardID) * Decimal(shardFactor) + Decimal(resourceID)).description
        }
        return id
    }

    public static var currentUser: ContextModel {
        return ContextModel(.user, id: "self")
    }

    public init(_ contextType: ContextType, id: String) {
        self.contextType = contextType
        self.id = ContextModel.expandTildeID(id)
    }

    private init?(parts: [Substring]) {
        guard parts.count >= 2 else { return nil }
        let rawValue = parts[0].lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "s"))
        guard let contextType = ContextType(rawValue: rawValue) else { return nil }
        self.init(contextType, id: String(parts[1]))
    }

    public init?(canvasContextID: String) {
        self.init(parts: canvasContextID.split(separator: "_"))
    }

    public init?(path: String) {
        self.init(parts: path.split(separator: "/").filter({ (s: Substring) in s != "api" && s != "v1" }))
    }

    public init?(url: URL) {
        self.init(path: url.path)
    }
}
