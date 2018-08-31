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
    }

    func testRouter() {
        let router = Router(routes: [
            Route("/courses") { _ in
                return UIViewController()
            },
            Route("/inbox") { _ in
                return UIViewController()
            },
        ])
        XCTAssert(router.count == 2)
    }

    func testRouteNoMatch() {
        let mockView = MockViewController()
        let router = Router(routes: [])
        router.route(to: "/", from: mockView)
        XCTAssertNil(mockView.shown)
    }

    func testRouteFallback() {
        let mockView = MockViewController()
        let router = Router(routes: [
            Route("/somewhere") { _ in
                return nil
            },
            Route("*path") { _ in
                return UIViewController()
            },
        ])
        router.route(to: "/somewhere", from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteComponents() {
        let mockView = MockViewController()
        let router = Router(routes: [
            Route("/somewhere") { _ in
                return UIViewController()
            },
        ])
        var components = URLComponents()
        components.path = "/somewhere"
        router.route(to: components, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteAbsoluteComponents() {
        let mockView = MockViewController()
        let router = Router(routes: [
            Route("/somewhere") { _ in
                return UIViewController()
            },
        ])
        let components = URLComponents(string: "https://canvas.instructure.com/somewhere")!
        router.route(to: components, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteURL() {
        let mockView = MockViewController()
        let router = Router(routes: [
            Route("/somewhere") { _ in
                return UIViewController()
            },
        ])
        let url = URL(string: "/somewhere")!
        router.route(to: url, from: mockView, options: .modal)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteAbsoluteURL() {
        let mockView = MockViewController()
        let router = Router(routes: [
            Route("/somewhere") { _ in
                return UIViewController()
            },
        ])
        let url = URL(string: "https://canvas.instructure.com/somewhere")!
        router.route(to: url, from: mockView, options: .modal)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteString() {
        let mockView = MockViewController()
        let router = Router(routes: [
            Route("/somewhere") { _ in
                return UIViewController()
            },
        ])
        let url = "/somewhere"
        router.route(to: url, from: mockView, options: .modal)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteAbsoluteString() {
        let mockView = MockViewController()
        let router = Router(routes: [
            Route("/somewhere") { _ in
                return UIViewController()
            },
        ])
        let url = "https://canvas.instructure.com/somewhere"
        router.route(to: url, from: mockView, options: .modal)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteBadString() {
        let mockView = MockViewController()
        let router = Router(routes: [
            Route("/somewhere ") { _ in
                return UIViewController()
            },
        ])
        router.route(to: "/somewhere ", from: mockView)
        XCTAssertNil(mockView.shown)
    }
}
