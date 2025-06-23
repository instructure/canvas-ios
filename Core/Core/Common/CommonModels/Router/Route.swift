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

<<<<<<<< HEAD:Core/Core/Common/CommonModels/Router/RouteHandler.swift
import UIKit

// A route is a place you can go in the app
// Each app defines it's own routes when creating the Router
public struct RouteHandler {
    public typealias ViewFactory = (URLComponents, [String: String], [String: Any]?, AppEnvironment) -> UIViewController?
    public typealias DiscardingEnvironmentViewFactory = (URLComponents, [String: String], [String: Any]?) -> UIViewController?
========
import Foundation

public struct Route {
>>>>>>>> origin/master:Core/Core/Common/CommonModels/Router/Route.swift

    public enum Segment: Equatable {
        case literal(String)
        case param(String)
        case splat(String)
    }

    public let template: String
    public let segments: [Segment]

<<<<<<<< HEAD:Core/Core/Common/CommonModels/Router/RouteHandler.swift
    public init(_ template: String, factory: @escaping ViewFactory = { _, _, _, _ in nil }) {
========
    public init(_ template: String) {
>>>>>>>> origin/master:Core/Core/Common/CommonModels/Router/Route.swift
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

    /// This is to avoid large file changes on Routes.
    /// We need to remove this while migrating to a state where AppEnvironment instance
    /// is being passed to all view of routes entry points.
    public init(_ template: String, factory: @escaping DiscardingEnvironmentViewFactory) {
        self.init(template) { url, params, userInfo, _ in
            factory(url, params, userInfo)
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
