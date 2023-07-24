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
import XCTest

class DiscussionWebPageViewModelTests: CoreTestCase {
    let timezoneName = TimeZone.current.identifier
    let locale = Locale.current.identifier.replacingOccurrences(of: "_", with: "-")

    func testURLWithoutSession() {
        AppEnvironment.shared.currentSession = nil
        let testee = EmbeddedWebPageViewModelLive(context: .course("1"), webPageType: .discussion(id: "123"))
        XCTAssertEqual(testee.url, URL(string: "/")!)
    }

    func testCourseURL() {
        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "https://instructure.com")!, userID: "", userName: "")
        let testee = EmbeddedWebPageViewModelLive(context: .course("1"), webPageType: .discussion(id: "123"))
        XCTAssertEqual(testee.url, URL(string: "https://instructure.com/courses/1/discussion_topics/123?embed=true&session_timezone=\(timezoneName)&session_locale=\(locale)")!)
    }

    func testGroupURL() {
        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "https://instructure.com")!, userID: "", userName: "")
        let testee = EmbeddedWebPageViewModelLive(context: .group("1"), webPageType: .discussion(id: "123"))
        XCTAssertEqual(testee.url, URL(string: "https://instructure.com/groups/1/discussion_topics/123?embed=true&session_timezone=\(timezoneName)&session_locale=\(locale)")!)
    }

    func testCourseProperties() {
        api.mock(GetCustomColors(), value: APICustomColors(custom_colors: ["course_1": "#BEEF00"]))
        api.mock(GetCourse(courseID: "1"), value: .make(name: "Test Name"))

        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "https://instructure.com")!, userID: "", userName: "")
        let testee = EmbeddedWebPageViewModelLive(context: .course("1"), webPageType: .discussion(id: "123"))

        XCTAssertEqual(testee.navTitle, "Discussion Details")
        XCTAssertEqual(testee.subTitle, "Test Name")
        XCTAssertEqual(testee.contextColor!.hexString, UIColor(hexString: "#BEEF00")!.ensureContrast(against: .backgroundLightest).hexString)
    }

    func testGroupProperties() {
        api.mock(GetCustomColors(), value: APICustomColors(custom_colors: ["group_1": "#BEEF00"]))
        api.mock(GetGroup(groupID: "1"), value: .make(name: "Test Group Name"))

        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "https://instructure.com")!, userID: "", userName: "")
        let testee = EmbeddedWebPageViewModelLive(context: .group("1"), webPageType: .discussion(id: "123"))

        XCTAssertEqual(testee.navTitle, "Discussion Details")
        XCTAssertEqual(testee.subTitle, "Test Group Name")
        XCTAssertEqual(testee.contextColor, UIColor(hexString: "#BEEF00"))
    }

    func testEnabledRedesignFeatureFlag() {
        let flag = FeatureFlag(context: databaseClient)
        flag.name = "react_discussions_post"
        flag.enabled = true
        flag.context = .course("1")

        XCTAssertTrue(EmbeddedWebPageViewModelLive.isRedesignEnabled(in: .course("1")))
    }

    func testDisabledRedesignFeatureFlag() {
        let flag = FeatureFlag(context: databaseClient)
        flag.name = "react_discussions_post"
        flag.enabled = false
        flag.context = .course("1")

        XCTAssertFalse(EmbeddedWebPageViewModelLive.isRedesignEnabled(in: .course("1")))
    }

    func testMissingRedesignFeatureFlag() {
        let flag = FeatureFlag(context: databaseClient)
        flag.name = "react_discussions_post_2"
        flag.enabled = true
        flag.context = .course("1")

        XCTAssertFalse(EmbeddedWebPageViewModelLive.isRedesignEnabled(in: .course("1")))
    }
}
