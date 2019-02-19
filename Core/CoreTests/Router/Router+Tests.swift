//
// Copyright (C) 2016-present Instructure, Inc.
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

import XCTest
@testable import Core

class RouterTests: XCTestCase {
    class MockViewController: UIViewController {
        var shown: UIViewController?
        override func show(_ vc: UIViewController, sender: Any?) {
            shown = vc
        }
        var presented: UIViewController?
        override func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
            presented = vc
            if let completion = completion {
                completion()
            }
        }
    }

    func testRouter() {
        let router = Router(routes: [
            RouteHandler("/courses") { _, _ in
                return UIViewController()
            },
            RouteHandler("/inbox") { _, _ in
                return UIViewController()
            },
        ])
        XCTAssert(router.count == 2)
    }

    func testRouteNoMatch() {
        let mockView = MockViewController()
        let router = Router(routes: [])
        router.route(to: URLComponents(string: "/")!, from: mockView, options: .modal)
        XCTAssertNil(mockView.presented)
    }

    func testRouteModal() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/modal") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: URLComponents(string: "/modal")!, from: mockView, options: .modal)
        XCTAssertNotNil(mockView.presented)
        XCTAssert(mockView.presented?.isKind(of: UINavigationController.self) == false)
    }

    func testRouteModalEmbeddedInNav() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/modalEmbed") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: URLComponents(string: "/modalEmbed")!, from: mockView, options: [.modal, .embedInNav])
        XCTAssertNotNil(mockView.presented)
        XCTAssert(mockView.presented?.isKind(of: UINavigationController.self) == true)
    }

    func testRouteMatch() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: URLComponents(string: "/somewhere")!, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteString() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: "/somewhere", from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteURL() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: URL(string: "https://canvas.instructure.com/somewhere")!, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteRoute() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler(.login) { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: .login, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testMatchFallback() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return nil
            },
            RouteHandler("*path") { _, _ in
                return UIViewController()
            },
        ])
        XCTAssertNotNil(router.match(URLComponents(string: "/somewhere")!))
    }

    func testMatch() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ])
        var components = URLComponents()
        components.path = "/somewhere"
        XCTAssertNotNil(router.match(components))
    }

    func testMatchAbsolute() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ])
        let components = URLComponents(string: "https://canvas.instructure.com/somewhere")!
        XCTAssertNotNil(router.match(components))
    }
}
