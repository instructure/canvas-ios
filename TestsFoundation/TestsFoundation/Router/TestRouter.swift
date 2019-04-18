//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import Core

public class TestRouter: RouterProtocol {
    public init() {}
    public var calls = [(URLComponents, UIViewController, Router.RouteOptions?)]()
    public var viewControllerCalls = [(UIViewController, UIViewController, Router.RouteOptions?)]()

    public func route(to url: URLComponents, from: UIViewController, options: Router.RouteOptions? = nil) {
        calls.append((url, from, options))
    }

    public func route(to viewController: UIViewController, from: UIViewController, options: Router.RouteOptions?) {
        viewControllerCalls.append((viewController, from, options))
    }

    public func lastRoutedTo(_ route: Route) -> Bool {
        return calls.last?.0 == route.url
    }
}
