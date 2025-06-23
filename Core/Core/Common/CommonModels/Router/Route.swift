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

public struct Route {

    public enum Segment: Equatable {
        case literal(String)
        case param(String)
        case splat(String)
    }

    public let template: String
    public let segments: [Segment]

    public init(_ template: String) {
        self.template = template
        self.segments = template.split(separator: "/").map { part in
            if part.hasPrefix("*") {
                return .splat(String(part.dropFirst()))
            } else if part.hasPrefix(":") {
                return .param(ID.expandTildeID(String(part.dropFirst())))
            }
            return .literal(String(part))
        }
    }

    public func match(_ url: URLComponents) -> [String: String]? {
        var parts = url.path.split(separator: "/")
        if parts.count >= 2, parts[0] == "api", parts[1] == "v1" {
            parts.removeFirst(2)
        }
        var params: [String: String] = [:]
        for segment in segments {
            switch segment {
            case .literal(let template):
                guard !parts.isEmpty else { return nil } // too short
                guard parts.removeFirst() == template else { return nil }
            case .param(let name):
                guard !parts.isEmpty else { return nil } // too short
                params[name] = ID.expandTildeID(String(parts.removeFirst()))
            case .splat(let name):
                params[name] = parts.joined(separator: "/")
                parts = []
            }
        }
        guard parts.isEmpty else { return nil } // too long
        return params
    }
}
