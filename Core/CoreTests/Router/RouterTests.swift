//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
            RouteHandler("/courses", name: "courses") { _, _ in
                return UIViewController()
            },
            RouteHandler("/inbox", name: "inbox") { _, _ in
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
            RouteHandler("/modal", name: "modal") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: URLComponents(string: "/modal")!, from: mockView, options: .modal)
        XCTAssertNotNil(mockView.presented)
        XCTAssert(mockView.presented?.isKind(of: UINavigationController.self) == false)
    }

    func testRouteFormSheet() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/formSheet", name: "formSheet") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: URLComponents(string: "/formSheet")!, from: mockView, options: [.modal, .formSheet])
        XCTAssertNotNil(mockView.presented)
        XCTAssertEqual(mockView.presented?.modalPresentationStyle, .formSheet)
    }

    func testRouteModalEmbeddedInNav() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/modalEmbed", name: "modal_embed") { _, _ in
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
            RouteHandler("/somewhere", name: "somewhere") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: URLComponents(string: "/somewhere")!, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteString() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere", name: "somewhere") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: "/somewhere", from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteURL() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere", name: "somewhere") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: URL(string: "https://canvas.instructure.com/somewhere")!, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteRoute() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler(.login, name: "login") { _, _ in
                return UIViewController()
            },
        ])
        router.route(to: .login, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testMatchFallback() {
        let router = Router(routes: [
            RouteHandler("/somewhere", name: "somewhere") { _, _ in
                return nil
            },
            RouteHandler("*path", name: "path") { _, _ in
                return UIViewController()
            },
        ])
        XCTAssertNotNil(router.match(URLComponents(string: "/somewhere")!))
    }

    func testMatch() {
        let router = Router(routes: [
            RouteHandler("/somewhere", name: "somewhere") { _, _ in
                return UIViewController()
            },
        ])
        var components = URLComponents()
        components.path = "/somewhere"
        XCTAssertNotNil(router.match(components))
    }

    func testMatchAbsolute() {
        let router = Router(routes: [
            RouteHandler("/somewhere", name: "somewhere") { _, _ in
                return UIViewController()
            },
        ])
        let components = URLComponents(string: "https://canvas.instructure.com/somewhere")!
        XCTAssertNotNil(router.match(components))
    }
}
