//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import UIKit

/**
 This class act as a container to hold a weakly referenced UIViewController. We expose this container to SwiftUI views through an environment variable to prevent SwiftUI views to retain the UIViewController and cause a memory leak.
 */
public class WeakViewController {
    public var value: UIViewController { weakValue ?? UIViewController() }
    public var view: UIView { value.view }
    private weak var weakValue: UIViewController?

    public init(_ value: UIViewController? = nil) {
        self.weakValue = value
    }

    public func setValue(_ value: UIViewController) {
        weakValue = value
    }
}

public extension Router {

    func route(to url: URL, userInfo: [String: Any]? = nil, from: WeakViewController, options: RouteOptions = DefaultRouteOptions) {
        route(to: url, userInfo: userInfo, from: from.value, options: options)
    }

    func route(to url: String, userInfo: [String: Any]? = nil, from: WeakViewController, options: RouteOptions = DefaultRouteOptions) {
        route(to: url, userInfo: userInfo, from: from.value, options: options)
    }

    func show(_ view: UIViewController, from: WeakViewController, options: RouteOptions = DefaultRouteOptions, analyticsRoute: String = "/unknown", completion: (() -> Void)? = nil) {
        show(view, from: from.value, options: options, analyticsRoute: analyticsRoute, completion: completion)
    }

    func pop(from: WeakViewController) {
        pop(from: from.value)
    }

    func dismiss(_ view: WeakViewController, completion: (() -> Void)? = nil) {
        dismiss(view.value, completion: completion)
    }
}

public extension FilePicker {

    func pickAttachments(from: WeakViewController, action: @escaping (String) -> Void) {
        pickAttachments(from: from.value, action: action)
    }

    func pickAttachment(from: WeakViewController, action: @escaping (Result<URL, Error>) -> Void) {
        pickAttachment(from: from.value, action: action)
    }
}
