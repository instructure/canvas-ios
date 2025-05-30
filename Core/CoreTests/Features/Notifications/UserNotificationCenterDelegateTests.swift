//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

@testable import Core
import TestsFoundation
import UserNotifications
import XCTest

class TestableUserNotificationCenterDelegate: UserNotificationCenterDelegate {
    var openURLClosure: ((URL, [String: Any]?) -> Bool)?

    override func openURL(_ url: URL, userInfo: [String: Any]? = nil) -> Bool {
        if let openURLClosure = openURLClosure {
            return openURLClosure(url, userInfo)
        }
        return super.openURL(url, userInfo: userInfo)
    }
}

class UserNotificationCenterDelegateTests: CoreTestCase {
    var delegate: TestableUserNotificationCenterDelegate!

    override func setUp() {
        super.setUp()
        delegate = TestableUserNotificationCenterDelegate(environment: environment)
    }

    func testWillPresentNotification() {
        let expectation = XCTestExpectation(description: "completion handler called")
        var presentationOptions: UNNotificationPresentationOptions?

        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)

        let notificationClass = UNNotification.self
        let notification = unsafeBitCast(
            notificationClass.perform(Selector(("notificationWithRequest:date:")), with: request, with: Date()),
            to: UNNotification.self
        )

        delegate.userNotificationCenter(
            UNUserNotificationCenter.current(),
            willPresent: notification,
            withCompletionHandler: { options in
                presentationOptions = options
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(presentationOptions, [.banner, .sound])
    }

    func testDidReceiveResponse() {
        let expectation = XCTestExpectation(description: "completion handler called")

        let content = UNMutableNotificationContent()
        content.userInfo = [
            "aps": ["alert": "Test message"],
            UNNotificationContent.RouteURLKey: "https://canvas.instructure.com/courses/1"
        ]

        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)

        let notificationClass = UNNotification.self
        let notification = unsafeBitCast(
            notificationClass.perform(Selector(("notificationWithRequest:date:")), with: request, with: Date()),
            to: UNNotification.self
        )

        let responseClass = UNNotificationResponse.self
        let response = unsafeBitCast(
            responseClass.perform(Selector(("responseWithNotification:actionIdentifier:")),
                                  with: notification,
                                  with: UNNotificationDefaultActionIdentifier),
            to: UNNotificationResponse.self
        )

        delegate.userNotificationCenter(
            UNUserNotificationCenter.current(),
            didReceive: response,
            withCompletionHandler: {
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1.0)
    }

    func testDidReceiveResponseWithURL() {
        var routedURL: URL?
        var routedUserInfo: [String: Any]?

        let mockDelegate = TestableUserNotificationCenterDelegate(environment: environment)
        mockDelegate.openURLClosure = { url, userInfo in
            routedURL = url
            routedUserInfo = userInfo
            return true
        }

        let testURL = "https://canvas.instructure.com/courses/1"

        let result = mockDelegate.openURL(URL(string: testURL)!, userInfo: [
            "forceRefresh": true,
            "pushNotification": ["alert": "Test message"]
        ])

        XCTAssertTrue(result)
        XCTAssertEqual(routedURL?.absoluteString, testURL)
        XCTAssertNotNil(routedUserInfo?["forceRefresh"] as? Bool)
        XCTAssertEqual(routedUserInfo?["forceRefresh"] as? Bool, true)
        XCTAssertNotNil(routedUserInfo?["pushNotification"])
    }

    func testOpenURLWithExistingLoginSession() {
        api.mock(GetUserProfileRequest(userID: "self"), value: APIProfile.make())
        environment.currentSession = LoginSession.make(baseURL: URL(string: "https://canvas.instructure.com")!)

        let viewController = UIViewController()
        environment.window?.rootViewController = viewController

        let router = environment.router as! TestRouter
        router.calls = []

        let url = URL(string: "https://canvas.instructure.com/courses/1")!
        let result = delegate.openURL(url)

        XCTAssertTrue(result)
        XCTAssertEqual(router.calls.count, 1)

        let expectedURLString = "https://canvas.instructure.com/courses/1?origin=notification"
        XCTAssertEqual(router.calls.first?.0?.url?.absoluteString, expectedURLString)
        XCTAssertEqual(router.calls.first?.2, .modal(embedInNav: true, addDoneButton: true))
    }
}
