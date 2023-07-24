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

import XCTest
import Core

public class TestRouter: Router {
    public init() {
        super.init(routes: []) { _, _, _, _ in }
    }
    public var calls = [(URLComponents?, UIViewController, RouteOptions)]()
    /// (presented, source, options)
    public var viewControllerCalls = [(UIViewController, UIViewController, RouteOptions)]()
    public var presented: UIViewController? {
        if viewControllerCalls.last?.2.isModal == true {
            return viewControllerCalls.last?.0
        }
        return nil
    }

    public var lastViewController: UIViewController? {
        viewControllerCalls.last?.0
    }

    public var dismissed: UIViewController?
    public var last: UIViewController? { viewControllerCalls.last?.0 }
    public var routes = [URLComponents: () -> UIViewController?]()

    public func mock(_ url: URLComponents, factory: @escaping () -> UIViewController?) {
        routes[url] = factory
    }

    public func mock(_ string: String, factory: @escaping () -> UIViewController?) {
        mock(.parse(URL(string: string)!), factory: factory)
    }

    public func dismiss() {
        guard let view = viewControllerCalls.last?.0 else { return }
        dismiss(view)
    }

    public override func match(_ url: URLComponents, userInfo: [String: Any]? = nil) -> UIViewController? {
        return routes[url]?()
    }

    public var routeExpectation = XCTestExpectation(description: "route")
    public override func route(to url: URLComponents, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = .push) {
        calls.append((url, from, options))
        routeExpectation.fulfill()
    }

    public var showExpectation = XCTestExpectation(description: "show")
    public override func show(_ view: UIViewController, from: UIViewController, options: RouteOptions, analyticsRoute: String? = "/unknown", completion: (() -> Void)? = nil) {
        var options = options
        if view is UIAlertController { options = .modal() }
        viewControllerCalls.append((view, from, options))
        showExpectation.fulfill()
        completion?()
    }

    public var popExpectation = XCTestExpectation(description: "pop")
    public override func pop(from: UIViewController) {
        popExpectation.fulfill()
    }

    public override func dismiss(_ view: UIViewController, completion: (() -> Void)? = nil) {
        dismissed = view
        if viewControllerCalls.last?.0 == view {
            viewControllerCalls.removeLast()
        }
        completion?()
    }

    public func lastRoutedTo(_ route: String) -> Bool {
        return lastRoutedTo(.parse(route))
    }

    public func lastRoutedTo(_ route: String, withOptions options: RouteOptions) -> Bool {
        return lastRoutedTo(route) && calls.last?.2 == options
    }

    public func lastRoutedTo(_ url: URL) -> Bool {
        return lastRoutedTo(.parse(url))
    }

    public func lastRoutedTo(_ url: URLComponents?) -> Bool {
        return calls.last?.0?.path == url?.path
    }

    public func lastRoutedTo(_ url: URL, withOptions options: RouteOptions) -> Bool {
        return lastRoutedTo(url) && calls.last?.2 == options
    }

    public func lastRoutedTo(viewController: UIViewController, from: UIViewController, withOptions options: RouteOptions) -> Bool {
        guard let last = viewControllerCalls.last else { return false }
        return last == (viewController, from, options)
    }

    public func resetExpectations() {
        routeExpectation = XCTestExpectation(description: "route")
        showExpectation = XCTestExpectation(description: "show")
        popExpectation = XCTestExpectation(description: "pop")
    }
}
