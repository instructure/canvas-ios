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

class RouterTests: CoreTestCase {
    class MockNavigationController: UINavigationController {
        override func popViewController(animated: Bool) -> UIViewController? {
            return viewControllers.popLast()
        }
    }
    class MockViewController: UIViewController {
        var shown: UIViewController?
        override func show(_ vc: UIViewController, sender: Any?) {
            shown = vc
        }
        var presented: UIViewController?
        override func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
            presented = vc
            completion?()
        }
        var detail: UIViewController?
        override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
            detail = vc
        }
    }

    class MockSplitViewController: UISplitViewController {
        var mockCollapsed: Bool?
        override var isCollapsed: Bool {
            return mockCollapsed ?? super.isCollapsed
        }
    }

    func testRouter() {
        let router = Router(routes: [
            RouteHandler("/courses") { _, _, _ in
                return UIViewController()
            },
            RouteHandler("/inbox") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        XCTAssert(router.count == 2)
    }

    func testRouteNoMatch() {
        let mockView = MockViewController()
        let router = Router(routes: []) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/")!, from: mockView, options: .modal())
        XCTAssertNil(mockView.presented)
    }

    func testRouteModal() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/modal") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/modal")!, from: mockView, options: .modal())
        XCTAssertNotNil(mockView.presented)
        XCTAssert(mockView.presented?.isKind(of: UINavigationController.self) == false)
    }

    func testRouteCleanURL() {
        var clean: URLComponents?
        let router = Router(routes: [
            RouteHandler("/match") { components, _, _ in
                clean = components
                return nil
            },
        ]) { _, _, _, _ in }
        router.route(to: .parse("/match?q=a+b&u=a%26b"), from: MockViewController())
        XCTAssertNotNil(clean)
        XCTAssertEqual(clean?.queryItems?[0], URLQueryItem(name: "q", value: "a b"))
        XCTAssertEqual(clean?.queryItems?[1], URLQueryItem(name: "u", value: "a&b"))
    }

    func testAddDoneButton() throws {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/modal") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/modal")!, from: mockView, options: .modal(embedInNav: true, addDoneButton: true))
        let nav = mockView.presented as? UINavigationController
        XCTAssertEqual(nav?.viewControllers.first?.navigationItem.leftBarButtonItems?.count, 1)
    }

    func testRouteFormSheet() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/formSheet") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/formSheet")!, from: mockView, options: .modal(.formSheet))
        XCTAssertNotNil(mockView.presented)
        XCTAssertEqual(mockView.presented?.modalPresentationStyle, .formSheet)
    }

    func testRouteModalEmbeddedInNav() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/modalEmbed") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/modalEmbed")!, from: mockView, options: .modal(embedInNav: true))
        XCTAssertNotNil(mockView.presented)
        XCTAssert(mockView.presented?.isKind(of: UINavigationController.self) == true)
    }

    func testRouteDetail() {
        let mockView = MockViewController()
        let split = UISplitViewController()
        split.viewControllers = [UINavigationController(rootViewController: mockView)]
        let router = Router(routes: [
            RouteHandler("/detail") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: .detail)
        XCTAssertNotNil(mockView.detail)
        XCTAssert(mockView.detail?.isKind(of: UIViewController.self) == true)
    }

    func testRouteDetailEmbedInNav() {
        let mockView = MockViewController()
        let split = UISplitViewController()
        split.viewControllers = [UINavigationController(rootViewController: mockView)]
        let router = Router(routes: [
            RouteHandler("/detail") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: .detail)
        XCTAssertNotNil(mockView.detail)
        XCTAssert(mockView.detail?.isKind(of: UINavigationController.self) == true)
    }

    func testRouteDetailNotInSplitViewDoesAShow() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/detail") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: .detail)
        XCTAssertNotNil(mockView.shown)
        XCTAssert(mockView.shown?.isKind(of: UIViewController.self) == true)
        XCTAssert(mockView.shown?.isKind(of: UINavigationController.self) == false)
    }

    func testRouteDetailInCollapsedSplitViewDoesAShow() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/detail") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        let split = MockSplitViewController()
        split.viewControllers = [UINavigationController(rootViewController: mockView)]
        split.mockCollapsed = true
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: .detail)
        XCTAssertNotNil(mockView.shown)
        XCTAssert(mockView.shown?.isKind(of: UIViewController.self) == true)
        XCTAssert(mockView.shown?.isKind(of: UINavigationController.self) == false)
    }

    func testRouteDetailFromDetailDoesAShow() {
        let mockView = MockViewController()
        let split = UISplitViewController()
        split.viewControllers = [UINavigationController(), UINavigationController(rootViewController: mockView)]
        let router = Router(routes: [
            RouteHandler("/detail") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options:
            .detail)
        XCTAssertNil(mockView.detail)
        XCTAssertNotNil(mockView.shown)
        XCTAssert(mockView.shown?.isKind(of: UIViewController.self) == true)
    }

    func testDetailSplitViewButtons() {
        let mockView = MockViewController()
        mockView.navigationItem.leftItemsSupplementBackButton = false
        mockView.navigationItem.leftBarButtonItems = nil
        let router = Router(routes: [
            RouteHandler("/detail") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }

        // not detail
        router.route(to: URLComponents(string: "/detail")!, from: mockView)
        XCTAssertNil(mockView.navigationItem.leftBarButtonItems?.first)
        XCTAssertFalse(mockView.navigationItem.leftItemsSupplementBackButton)

        let split = MockSplitViewController()
        split.viewControllers = [UIViewController(), UINavigationController(rootViewController: mockView)]

        // to detail
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: .detail)
        XCTAssertNotNil(mockView.shown?.navigationItem.leftBarButtonItems?.first)
        XCTAssert(mockView.shown?.navigationItem.leftItemsSupplementBackButton == true)

        // from detail
        mockView.navigationItem.leftBarButtonItems = nil
        mockView.navigationItem.leftItemsSupplementBackButton = false
        router.route(to: URLComponents(string: "/detail")!, from: mockView)
        XCTAssertNotNil(mockView.shown?.navigationItem.leftBarButtonItems?.first)
        XCTAssert(mockView.shown?.navigationItem.leftItemsSupplementBackButton == true)

        // compact
        split.mockCollapsed = true
        router.route(to: URLComponents(string: "/detail")!, from: mockView)
        XCTAssertNil(mockView.shown?.navigationItem.leftBarButtonItems?.first)
        XCTAssert(mockView.shown?.navigationItem.leftItemsSupplementBackButton == false)

        // modal
        split.mockCollapsed = false
        router.route(to: URLComponents(string: "/detail")!, from: mockView, options: .modal())
        XCTAssertNil(mockView.presented?.navigationItem.leftBarButtonItems?.first)
        XCTAssert(mockView.presented?.navigationItem.leftItemsSupplementBackButton == false)
    }

    func testRouteMatch() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: URLComponents(string: "/somewhere")!, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteString() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: "/somewhere", from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteURL() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        let url = URL(string: "https://canvas.instructure.com/somewhere#fragment?query=yo")!
        router.route(to: url, from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testRouteApiV1() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        router.route(to: "/api/v1/somewhere", from: mockView)
        XCTAssertNotNil(mockView.shown)
    }

    func testMatchNoFallback() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _, _ in
                return nil
            },
            RouteHandler("*path") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        XCTAssertNil(router.match(URLComponents(string: "/somewhere")!))
    }

    func testMatch() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        var components = URLComponents()
        components.path = "/somewhere"
        XCTAssertNotNil(router.match(components))
    }

    func testMatchAbsolute() {
        let router = Router(routes: [
            RouteHandler("/somewhere") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        let components = URLComponents(string: "https://canvas.instructure.com/somewhere")!
        XCTAssertNotNil(router.match(components))
    }

    func testShowAlertController() {
        let mockView = MockViewController()
        let router = Router(routes: []) { _, _, _, _ in }
        router.show(UIAlertController(title: nil, message: nil, preferredStyle: .alert), from: mockView)
        XCTAssertNil(mockView.shown)
        XCTAssert(mockView.presented is UIAlertController)
    }

    func testPopViewController() {
        let router = Router(routes: []) { _, _, _, _ in }
        let rootViewController = UIViewController()
        let navController = MockNavigationController(rootViewController: rootViewController)

        let childViewController = UIViewController()
        navController.viewControllers.append(childViewController)
        XCTAssertEqual(navController.viewControllers.count, 2)

        router.pop(from: childViewController)
        XCTAssertEqual(navController.viewControllers.count, 1)

        router.pop(from: rootViewController)
        XCTAssertEqual(navController.viewControllers.count, 1)
        XCTAssert(navController.viewControllers.first is EmptyViewController)
    }

    func testIsDismissable() {
        let mockView = MockViewController()
        let router = Router(routes: []) { _, _, _, _ in }
        router.show(mockView, from: UIViewController(), options: .modal())
        XCTAssertFalse(mockView.isModalInPresentation)
        router.show(mockView, from: UIViewController(), options: .modal(isDismissable: false))
        XCTAssertTrue(mockView.isModalInPresentation)
        router.show(mockView, from: UIViewController(), options: .modal(isDismissable: false, embedInNav: true))
        XCTAssertNotNil(mockView.navigationController)
        XCTAssertEqual(mockView.navigationController?.isModalInPresentation, true)
    }

    func testFullScreen() {
        let mockView = MockViewController()
        let router = Router(routes: []) { _, _, _, _ in }
        router.show(mockView, from: UIViewController(), options: .modal())
        XCTAssertNotEqual(mockView.modalPresentationStyle, .fullScreen)
        router.show(mockView, from: UIViewController(), options: .modal(.fullScreen))
        XCTAssertEqual(mockView.modalPresentationStyle, .fullScreen)
        router.show(mockView, from: UIViewController(), options: .modal(.fullScreen, embedInNav: true))
        XCTAssertNotNil(mockView.navigationController)
        XCTAssertEqual(mockView.navigationController?.modalPresentationStyle, .fullScreen)
    }

    func testOpen() {
        var url = URL(string: "https://canvas.instructure.com/relative/url")!
        api.mock(GetWebSessionRequest(to: url), value: .init(session_url: url, requires_terms_acceptance: false))
        Router.open(url: .parse("relative/url"))
        XCTAssertEqual(login.externalURL?.absoluteURL, url)

        url = URL(string: "https://canvas.instructure.com/root/relative/url")!
        api.mock(GetWebSessionRequest(to: url), value: nil)
        Router.open(url: .parse("/root/relative/url"))
        XCTAssertEqual(login.externalURL?.absoluteURL, url)

        url = URL(string: "http://insecure.protocol/")!
        api.mock(GetWebSessionRequest(to: url), value: nil)
        Router.open(url: .parse("http://insecure.protocol/"))
        XCTAssertEqual(login.externalURL?.absoluteURL, url)

        url = URL(string: "https://absolute.com")!
        api.mock(GetWebSessionRequest(to: url), value: nil)
        Router.open(url: .parse(url))
        XCTAssertEqual(login.externalURL?.absoluteURL, url)

        url = URL(string: "tel:+18002036755")!
        Router.open(url: .parse(url))
        XCTAssertEqual(login.externalURL?.absoluteURL, url)

        url = URL(string: "mailto:support@email.example")!
        Router.open(url: .parse(url))
        XCTAssertEqual(login.externalURL?.absoluteURL, url)

        url = URL(string: "https://canvas.instructure.com/")!
        api.mock(GetWebSessionRequest(to: url), value: nil)
        for proto in [ "canvas-courses", "canvas-student", "canvas-teacher", "canvas-parent" ] {
            Router.open(url: .parse("\(proto)://canvas.instructure.com/"))
            XCTAssertEqual(login.externalURL?.absoluteURL, url)
        }
    }

    func testAnalyticsReportOnRoute() {
        let mockView = MockViewController()
        let router = Router(routes: [
            RouteHandler("/courses/:courseId/assignments") { _, _, _ in
                return UIViewController()
            },
        ]) { _, _, _, _ in }
        AppEnvironment.shared.app = .teacher
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler

        router.route(to: URLComponents(string: "/courses/1234/assignments")!, from: mockView, options: .modal())

        XCTAssertEqual(analyticsHandler.lastEventName, "screen_view")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: String], [
            "application": "teacher",
            "screen_name": "/courses/:courseId/assignments",
            "screen_class": "UIViewController",
        ])
    }

    func testAnalyticsReportOnShow() {
        let mockView = MockViewController()
        let router = Router(routes: []) { _, _, _, _ in }
        AppEnvironment.shared.app = .parent
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler

        router.show(mockView, from: UIViewController(), analyticsRoute: "/courses/:courseId/assignments")

        XCTAssertEqual(analyticsHandler.loggedEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEventName, "screen_view")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: String], [
            "application": "parent",
            "screen_name": "/courses/:courseId/assignments",
            "screen_class": "MockViewController",
        ])
    }

    func testRouteTemplate() {
        let testee = Router(routes: [
            RouteHandler("/courses/:courseId/assignments") { _, _, _ in UIViewController() },
        ])

        XCTAssertEqual(testee.template(for: "/courses/1234/assignments"), "/courses/:courseId/assignments")
        XCTAssertEqual(testee.template(for: URLComponents(string: "/courses/1234/assignments")!), "/courses/:courseId/assignments")
        XCTAssertEqual(testee.template(for: URL(string: "/courses/1234/assignments")!), "/courses/:courseId/assignments")
    }

    func testIsRegisteredRoute() {
        let testee = Router(routes: [
            RouteHandler("/courses/:courseId/assignments") { _, _, _ in UIViewController() },
        ])

        XCTAssertEqual(testee.isRegisteredRoute("/courses/1234/assignments"), true)
        XCTAssertEqual(testee.isRegisteredRoute("/courses/1234/assignments/4321"), false)
        XCTAssertEqual(testee.isRegisteredRoute(URLComponents(string: "/courses/1234/assignments")!), true)
        XCTAssertEqual(testee.isRegisteredRoute(URLComponents(string: "/courses/1234/assignments/4321")!), false)
        XCTAssertEqual(testee.isRegisteredRoute(URL(string: "/courses/1234/assignments")!), true)
        XCTAssertEqual(testee.isRegisteredRoute(URL(string: "/courses/1234/assignments/4321")!), false)
    }

    func testExternalURLsWithMatchingPathOfANativeRouteOpenedBySystem() {
        AppEnvironment.shared.currentSession = LoginSession(baseURL: URL(string: "https://canvas.com")!,
                                                            userID: "",
                                                            userName: "")
        let mockViewController = MockViewController()
        let externalURL = URL(string: "https://example.com/courses")!
        let testee = Router(routes: [
            RouteHandler("/courses") { _, _, _ in UIViewController() },
        ])

        testee.route(to: externalURL, from: mockViewController)

        XCTAssertEqual(login.externalURL?.absoluteURL, URL(string: "https://example.com/courses")!)
        XCTAssertNil(mockViewController.shown)
    }

    func testExternalURLsFromPushOpenedNatively() {
        AppEnvironment.shared.currentSession = LoginSession(baseURL: URL(string: "https://canvas.com")!,
                                                            userID: "",
                                                            userName: "")
        let mockViewController = MockViewController()
        var externalURLComponents = URLComponents(string: "https://example.com/courses")!
        externalURLComponents.originIsNotification = true
        let externalURL = externalURLComponents.url!
        let testee = Router(routes: [
            RouteHandler("/courses") { _, _, _ in UIViewController() },
        ])

        testee.route(to: externalURL, from: mockViewController)

        XCTAssertNil(login.externalURL)
        XCTAssertNotNil(mockViewController.shown)
    }

    func testExternalWebsitePopupReportedToAnalytics() {
        let mockViewController = MockViewController()
        let testee = Router(routes: []) { _, _, _, _ in }
        let externalURL = URL(string: "https://example.com/courses")!
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler

        testee.route(to: externalURL, from: mockViewController)

        XCTAssertEqual(analyticsHandler.loggedEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEventName, "screen_view")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: String], [
            "application": "student",
            "screen_name": "/external_url",
            "screen_class": "unknown",
        ])
    }
}
