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
public struct RouteHandler {
    public typealias ViewFactory = (URLComponents, [String: String]) -> UIViewController?

    public enum Segment: Equatable {
        case literal(String)
        case param(String)
        case splat(String)
    }

    public let template: String
    public let factory: ViewFactory
    public let segments: [Segment]

    public init(_ route: Route, factory: @escaping ViewFactory) {
        self.init(route.url.path, factory: factory)
    }

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

    public func match(_ url: URLComponents) -> UIViewController? {
        var parts = url.path.split(separator: "/")
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

        // URLComponents does all the encoding we care about except we often have + meaning space in query
        var cleaned = url
        cleaned.query = url.query?.replacingOccurrences(of: "+", with: " ")

        return factory(cleaned, params)
    }
}
