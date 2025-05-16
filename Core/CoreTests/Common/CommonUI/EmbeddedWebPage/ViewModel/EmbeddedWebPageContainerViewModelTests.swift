//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import WebKit
import XCTest

class EmbeddedWebPageContainerViewModelTests: CoreTestCase {
    let timezoneName = TimeZone.current.identifier
    let locale = Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
    private let mockWebPageViewModel = MockWebPageViewModel()
    let testWebView = WKWebView()
    let testNavigation = WKNavigation()

    func testURLWithoutSession() {
        AppEnvironment.shared.currentSession = nil

        // WHEN
        let testee = EmbeddedWebPageContainerViewModel(
            context: .course("1"),
            webPageModel: mockWebPageViewModel,
            env: environment
        )

        // THEN
        XCTAssertEqual(testee.url, .make())
    }

    func testCourseURL() {
        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "https://instructure.com")!, userID: "", userName: "")

        // WHEN
        let testee = EmbeddedWebPageContainerViewModel(
            context: .course("1"),
            webPageModel: mockWebPageViewModel,
            env: environment
        )

        // THEN
        XCTAssertEqual(
            testee.url,
            URL(string: "https://instructure.com/courses/1/\(mockWebPageViewModel.urlPathComponent)?embed=true&session_timezone=\(timezoneName)&session_locale=\(locale)")!
        )
    }

    func testGroupURL() {
        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "https://instructure.com")!, userID: "", userName: "")

        // WHEN
        let testee = EmbeddedWebPageContainerViewModel(
            context: .group("1"),
            webPageModel: mockWebPageViewModel,
            env: environment
        )

        // THEN
        XCTAssertEqual(
            testee.url,
            URL(string: "https://instructure.com/groups/1/\(mockWebPageViewModel.urlPathComponent)?embed=true&session_timezone=\(timezoneName)&session_locale=\(locale)")!
        )
    }

    func testCourseProperties() {
        api.mock(GetCustomColors(), value: APICustomColors(custom_colors: ["course_1": "#BEEF00"]))
        api.mock(GetCourse(courseID: "1"), value: .make(name: "Test Name"))
        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "https://instructure.com")!, userID: "", userName: "")

        // WHEN
        let testee = EmbeddedWebPageContainerViewModel(
            context: .course("1"),
            webPageModel: mockWebPageViewModel,
            env: environment
        )

        // THEN
        XCTAssertEqual(testee.navTitle, mockWebPageViewModel.navigationBarTitle)
        XCTAssertEqual(testee.subTitle, "Test Name")
        XCTAssertEqual(testee.contextColor!.hexString, UIColor(hexString: "#BEEF00")!.ensureContrast(against: .backgroundLightest).hexString)
    }

    func testGroupProperties() {
        api.mock(GetCustomColors(), value: APICustomColors(custom_colors: ["group_1": "#BEEF00"]))
        api.mock(GetGroup(groupID: "1"), value: .make(name: "Test Group Name"))
        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "https://instructure.com")!, userID: "", userName: "")

        // WHEN
        let testee = EmbeddedWebPageContainerViewModel(
            context: .group("1"),
            webPageModel: mockWebPageViewModel,
            env: environment
        )

        // THEN
        XCTAssertEqual(testee.navTitle, mockWebPageViewModel.navigationBarTitle)
        XCTAssertEqual(testee.subTitle, "Test Group Name")
        XCTAssertEqual(
            testee.contextColor!.hexString,
            CourseColorsInteractorLive().courseColorFromAPIColor("#BEEF00").hexString
        )
    }

    func testForwardsProvisionalNavigationStartCallback() {
        let testee = EmbeddedWebPageContainerViewModel(
            context: .course("1"),
            webPageModel: mockWebPageViewModel,
            env: environment
        )

        // WHEN
        testee.webView(testWebView, didStartProvisionalNavigation: testNavigation)

        // THEN
        XCTAssertTrue(mockWebPageViewModel.didCallProvisionalNavigationStartCallback)
    }
}

private class MockWebPageViewModel: EmbeddedWebPageViewModel {
    let urlPathComponent: String = "test"
    let navigationBarTitle: String = "Embedded Nav Title"
    let queryItems: [URLQueryItem] = []
    let assetID: String? = nil

    private(set) var didCallProvisionalNavigationStartCallback = false

    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        didCallProvisionalNavigationStartCallback = true
    }
}
