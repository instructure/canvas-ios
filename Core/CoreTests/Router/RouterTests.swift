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
        var detail: UIViewController?
        override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
            detail = vc
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
        ]) { _, _, _ in }
        XCTAssert(router.count == 2)
    }

    func testRouteNoMatch() {
        let mockView = MockViewController()
        let router = Router(routes: []) { _, _, _ in }
        router.route(to: URLComponents(string: "/")!, from: mockView, options: .modal)
        XCTAssertNil(mockView.presented)
    }

    func testRouteModal() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/modal") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: URLComponents(string: "/modal")!, from: mockView, options: .modal)
        XCTAssertNotNil(mockView.presented)
        XCTAssert(mockView.presented?.isKind(of: UINavigationController.self) == false)
    }

    func testRouteFormSheet() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/formSheet") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: URLComponents(string: "/formSheet")!, from: mockView, options: [.modal, .formSheet])
        XCTAssertNotNil(mockView.presented)
        XCTAssertEqual(mockView.presented?.modalPresentationStyle, .formSheet)
    }

    func testRouteModalEmbeddedInNav() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/modalEmbed") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: URLComponents(string: "/modalEmbed")!, from: mockView, options: [.modal, .embedInNav])
        XCTAssertNotNil(mockView.presented)
        XCTAssert(mockView.presented?.isKind(of: UINavigationController.self) == true)
    }

    func testRouteDetail() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/detail") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: [.detail])
        XCTAssertNotNil(mockView.detail)
        XCTAssert(mockView.detail?.isKind(of: UIViewController.self) == true)
    }

    func testRouteDetailEmbedInNav() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/detail") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: [.detail, .embedInNav])
        XCTAssertNotNil(mockView.detail)
        XCTAssert(mockView.detail?.isKind(of: UINavigationController.self) == true)
    }

    func testRouteDetailFromDetailDoesAShow() {
        let mockView = MockViewController()
        let split = UISplitViewController()
        split.viewControllers = [UINavigationController(), UINavigationController(rootViewController: mockView)]
        let router = Router(routes: [
            RouteHandler("/detail") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: [.detail, .embedInNav])
        XCTAssertNil(mockView.detail)
        XCTAssertNotNil(mockView.shown)
        XCTAssert(mockView.shown?.isKind(of: UIViewController.self) == true)
    }

    func testDetailSplitViewButtons() {
        let mockView = MockViewController()
        mockView.navigationItem.leftItemsSupplementBackButton = false
        mockView.navigationItem.leftBarButtonItems = nil
        let router = Router(routes: [
            RouteHandler("/detail") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }

        // not detail
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: nil)
        XCTAssertNil(mockView.navigationItem.leftBarButtonItems?.first)
        XCTAssertFalse(mockView.navigationItem.leftItemsSupplementBackButton)

        let split = UISplitViewController()
        split.viewControllers = [UIViewController(), UINavigationController(rootViewController: mockView)]

        // to detail
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: [.detail])
        XCTAssertNotNil(mockView.shown?.navigationItem.leftBarButtonItems?.first)
        XCTAssert(mockView.shown?.navigationItem.leftItemsSupplementBackButton == true)

        // from detail
        mockView.navigationItem.leftBarButtonItems = nil
        mockView.navigationItem.leftItemsSupplementBackButton = false
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: nil)
        XCTAssertNotNil(mockView.shown?.navigationItem.leftBarButtonItems?.first)
        XCTAssert(mockView.shown?.navigationItem.leftItemsSupplementBackButton == true)
    }

    func testRouteMatch() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: URLComponents(string: "/somewhere")!, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteString() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: "/somewhere", from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteURL() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: URL(string: "https://canvas.instructure.com/somewhere")!, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteRoute() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler(.courses) { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: .courses, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteApiV1() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        router.route(to: "/api/v1/somewhere", from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testMatchNoFallback() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return nil
            },
            RouteHandler("*path") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        XCTAssertNil(router.match(URLComponents(string: "/somewhere")!))
    }

    func testMatch() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        var components = URLComponents()
        components.path = "/somewhere"
        XCTAssertNotNil(router.match(components))
    }

    func testMatchAbsolute() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _ in
                return UIViewController()
            },
        ]) { _, _, _ in }
        let components = URLComponents(string: "https://canvas.instructure.com/somewhere")!
        XCTAssertNotNil(router.match(components))
    }

    func testShowAlertController() {
        let mockView = MockViewController()
        let router = Router(routes: []) { _, _, _ in }
        router.show(UIAlertController(title: nil, message: nil, preferredStyle: .alert), from: mockView, options: nil)
        XCTAssertNil(mockView.shown)
        XCTAssert(mockView.presented is UIAlertController)
    }
}
