//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Combine
import WebKit
import XCTest

class StudioAPIAuthInteractorLiveTests: CoreTestCase {
    enum TestData {
        static let studioLaunchURL = URL(string: "https://test.instructuremedia.com/ltiLaunch")!
        static let studioAuthenticatedLaunchURL = URL(string: "test.instructuremedia.com/auth")!
        static let studioWebToken = "testToken"
        static let studioWebUserID = "testUserID"
    }

    func testAuthenticationFlow() {
        mockStudioLTIData()
        mockSessionlessLaunchResponse()
        let mockWebView = MockWKWebView()

        let expectedAPIResult = API(
            LoginSession(
                accessToken: "user_id=\"\(TestData.studioWebUserID)\", token=\"\(TestData.studioWebToken)\"",
                baseURL: URL(string: "https://test.instructuremedia.com")!,
                userID: "",
                userName: ""
            )
        )
        let publisher = StudioAPIAuthInteractorLive(webViewFactory: { mockWebView }).makeStudioAPI(env: environment)

        XCTAssertFirstValueAndCompletion(publisher, timeout: 14) { api in
            XCTAssertEqual(api.loginSession, expectedAPIResult.loginSession)
        }

        XCTAssertEqual(mockWebView.receivedIsLoadingCheck, true)
        XCTAssertEqual(mockWebView.receivedRequestToLoad, URLRequest(url: TestData.studioAuthenticatedLaunchURL))
        XCTAssertEqual(mockWebView.receivedQueryForUserID, true)
        XCTAssertEqual(mockWebView.receivedQueryForToken, true)
    }

    func testErrorDescription() {
        XCTAssertEqual(StudioAPIAuthError.failedToGetLTIs.debugDescription, "StudioAPIAuthError.failedToGetLTIs")
    }

    private func mockStudioLTIData() {
        api.mock(
            GetGlobalNavExternalToolsPlacements(
                enrollment: .student
            ),
            value: [.make(
                domain: LTIDomains.studio.rawValue,
                placements: [ExternalToolLaunchPlacementLocation.global_navigation.rawValue: .init(
                    title: "",
                    url: TestData.studioLaunchURL
                )]
            )]
        )
    }

    private func mockSessionlessLaunchResponse() {
        let request = GetSessionlessLaunchURLRequest(
            context: .account("self"),
            id: nil,
            url: TestData.studioLaunchURL,
            assignmentID: nil,
            moduleItemID: nil,
            launchType: nil,
            resourceLinkLookupUUID: nil
        )

        api.mock(
            request,
            value: .init(name: "", url: TestData.studioAuthenticatedLaunchURL)
        )
    }

    private class MockWKWebView: WKWebView {
        private(set) var receivedIsLoadingCheck = false
        private(set) var receivedRequestToLoad: URLRequest?
        private(set) var receivedQueryForToken = false
        private(set) var receivedQueryForUserID = false

        override var isLoading: Bool {
            receivedIsLoadingCheck = true
            return false
        }

        override func load(_ request: URLRequest) -> WKNavigation? {
            receivedRequestToLoad = request
            return nil
        }

        override func evaluateJavaScript(_ javaScriptString: String, completionHandler: (@MainActor (Any?, (any Error)?) -> Void)? = nil) {
            switch javaScriptString {
            case "sessionStorage.getItem('token')":
                receivedQueryForToken = true
                completionHandler?(TestData.studioWebToken, nil)
            case "sessionStorage.getItem('userId')":
                receivedQueryForUserID = true
                completionHandler?(TestData.studioWebUserID, nil)
            default:
                break
            }
        }
    }
}
