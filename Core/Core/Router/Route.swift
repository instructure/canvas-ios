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
import UIKit

// A route is a place you can go in the app
// Each app defines it's own routes when creating the Router
public struct Route {
    public typealias ViewFactory = (Match) -> UIViewController?

    public enum Segment: Equatable {
        case literal(String)
        case param(String)
        case splat(String)
    }

    public struct Match {
        public let path: String
        public let params: [String: String]
        public let query: [String: String]
        public let fragment: String?
    }

    public let template: String
    public let factory: ViewFactory
    public let segments: [Segment]

    public init(_ template: String, factory: @escaping ViewFactory) {
        self.template = template
        self.factory = factory
        self.segments = template.split(separator: "/").map { part in
            if part.hasPrefix("*") {
                return .splat(String(part.dropFirst()))
            } else if part.hasPrefix(":") {
                return .param(String(part.dropFirst()))
            }
            return .literal(String(part))
        }
    }

    public func match(_ components: URLComponents) -> UIViewController? {
        var parts = components.path.split(separator: "/")
        var params: [String: String] = [:]
        for segment in segments {
            guard !parts.isEmpty else { return nil } // too short
            switch segment {
            case .literal(let template):
                guard parts.removeFirst() == template else { return nil }
            case .param(let name):
                params[name] = String(parts.removeFirst())
            case .splat(let name):
                params[name] = parts.joined(separator: "/")
                parts = []
            }
        }
        guard parts.isEmpty else { return nil } // too long

        var query: [String: String] = [:]
        for item in components.queryItems ?? [] {
            query[item.name] = item.value?.replacingOccurrences(of: "+", with: " ") ?? ""
        }

        return factory(Match(path: components.path, params: params, query: query, fragment: components.fragment))
    }
}
