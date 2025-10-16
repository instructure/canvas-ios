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

import XCTest
import TestsFoundation
@testable import Core

final class ContextTabUrlInteractorTests: CoreTestCase {

    private var testee: ContextTabUrlInteractor!

    override func setUp() {
        super.setUp()
        testee = .init()
        testee.setupTabSubscription()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - No tab subscription

    func test_isAllowedUrl_whenNotSetup_shouldAllowAll() {
        testee = .init()

        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/api/v1/courses/42/users?per_page=100&include%5B%5D=sections&no_verifiers=1")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/42/users")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/users")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/unknown_thing")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/1234")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/1234/")), true)

        verifyUnrelatedURLsAreAllowed()
    }

    // MARK: - Enabled / Disabled tabs

    func test_isAllowedUrl_whenSetupWithTabs_shouldAllowOnlyEnabledTabs() {
        saveTab(htmlUrl: "/courses/42/stuff", context: .course("42"))
        saveTab(htmlUrl: "/courses/42/users", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/users")), true)

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/modules")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/unknown_thing")), false)

        verifyUnrelatedURLsAreAllowed()
    }

    func test_isAllowedUrl_whenUrlIsNotCourseTab_shouldAllow() {
        saveTab(htmlUrl: "/courses/42/_something_", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/groups/42/stuff")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/users/self/files")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/users/42/settings")), true)
    }

    func test_isAllowedUrl_whenTabIsDisabledInAnotherCourse_shouldBlockOnlyForThatCourse() {
        saveTab(htmlUrl: "/courses/7/not_stuff", context: .course("7"))
        saveTab(htmlUrl: "/courses/42/stuff", context: .course("42"))

        // tab disabled in course -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/7/stuff")), false)

        // tab enabled in course -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff")), true)

        // tab in unknown course -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/0/stuff")), true)
    }

    // MARK: - Hide only tabs

    func test_isAllowedUrl_whenUrlIsHideOnlyTab_shouldAllow() {
        saveTab(htmlUrl: "/courses/42/_something_", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/grades")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/discussion_topics")), true)

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/not_grades_or_discussuions")), false)

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools/466")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools")), false)
    }

    // MARK: - UserInfo

    func test_isAllowedUrlWithUserInfo_whenBlockDisabledTabIsFalse_shouldAllowDisabledTab() {
        saveTab(htmlUrl: "/courses/42/not_stuff", context: .course("42"))

        let isAllowedUrl = testee.isAllowedUrl(
            .make("/courses/42/stuff"),
            userInfo: [ContextTabUrlInteractor.blockDisabledTabUserInfoKey: false]
        )
        XCTAssertEqual(isAllowedUrl, true)

        verifyUnrelatedURLsAreAllowed()
    }

    func test_isAllowedUrlWithUserInfo_whenBlockDisabledTabIsTrue_shouldBlockDisabledTab() {
        saveTab(htmlUrl: "/courses/42/not_stuff", context: .course("42"))

        let isAllowedUrl = testee.isAllowedUrl(
            .make("/courses/42/stuff"),
            userInfo: [ContextTabUrlInteractor.blockDisabledTabUserInfoKey: true]
        )
        XCTAssertEqual(isAllowedUrl, false)

        verifyUnrelatedURLsAreAllowed()
    }

    func test_isAllowedUrlWithUserInfo_whenBlockDisabledTabIsNotSet_shouldBlockDisabledTab() {
        saveTab(htmlUrl: "/courses/42/not_stuff", context: .course("42"))

        let isAllowedUrl = testee.isAllowedUrl(
            .make("/courses/42/stuff"),
            userInfo: [:]
        )
        XCTAssertEqual(isAllowedUrl, false)

        verifyUnrelatedURLsAreAllowed()
    }

    // MARK: - Tab Format rules

    func test_isAllowedUrl_whenTabIsDisabled_shouldBlockAllVariants() {
        saveTab(htmlUrl: "/courses/42/not_stuff", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/api/v1/courses/42/stuff?per_page=100&include%5B%5D=sections&no_verifiers=1")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff?display=borderless")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff#foo")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/42/stuff")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff/")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("courses/42/stuff")), false)
    }

    func test_isAllowedUrl_whenTabIsEnabled_shouldAllowAllVariants() {
        saveTab(htmlUrl: "/courses/42/stuff", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/api/v1/courses/42/stuff?per_page=100&include%5B%5D=sections&no_verifiers=1")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff?display=borderless")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff#foo")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/42/stuff")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff/")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("courses/42/stuff")), true)
    }

    func test_isAllowedUrl_whenTabWithQueryIsEnabled_shouldAllowAllVariants() {
        saveTab(htmlUrl: "/courses/42/stuff?display=borderless", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/api/v1/courses/42/stuff?per_page=100&include%5B%5D=sections&no_verifiers=1")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff?display=borderless")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff#foo")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/42/stuff")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff/")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("courses/42/stuff")), true)
    }

    func test_isAllowedUrl_whenTabWithFragmentIsEnabled_shouldAllowAllVariants() {
        saveTab(htmlUrl: "/courses/42/stuff#foo", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/api/v1/courses/42/stuff?per_page=100&include%5B%5D=sections&no_verifiers=1")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff?display=borderless")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff#foo")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/courses/42/stuff#bar")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/42/stuff")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff/")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("courses/42/stuff")), true)
    }

    func test_isAllowedUrl_whenTabIsDisabled_shouldAllowSubpages() {
        saveTab(htmlUrl: "/courses/42/not_stuff", context: .course("42"))

        // subpage -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff/123")), true)

        // tab -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff")), false)
    }

    func test_isAllowedUrl_whenTabIsDisabled_shouldAllowNonTabNavigationPaths() {
        saveTab(htmlUrl: "/courses/42/_something_", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/tabs")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/activity_stream")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/settings")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/details")), true)

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/something_not_known_but_tablike")), false)
    }

    func test_isAllowedUrl_whenSyllabusIsDisabled_shouldBlockSyllabusUrlFormat() {
        saveTab(htmlUrl: "/courses/42/not_syllabus", context: .course("42"))

        // matching special format -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/assignments/syllabus")), false)

        // matching basic format -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/syllabus")), false)

        // not matching format -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/any_component_here/syllabus")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/assignments/syllabus/something")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/syllabus/something")), true)
    }

    func test_isAllowedUrl_whenPagesIsDisabled_shouldBlockFrontPageUrlFormat() {
        saveTab(htmlUrl: "/courses/42/not_pages", context: .course("42"))

        // matching special format -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/pages/front_page")), false)

        // matching basic format -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/front_page")), false)

        // not matching format -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/any_component_here/front_page")), true)
    }

    func test_isAllowedUrl_whenExternalToolsIsDisabled_shouldAllowExternalToolsUrlFormat() {
        saveTab(htmlUrl: "/courses/42/not_external_tools", context: .course("42"))

        // matching special format for tools -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools/1234")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools/something")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools/syllabus")), true)

        // matching basic (but still disabled) format -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools")), false)

        // not matching format -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools/1234/something")), true)
    }

    // MARK: - Setup enabled tabs

    func test_setupEnabledTabs_shouldUseHtmlUrl() {
        let apiTab = APITab.make(
            id: "people",
            html_url: URL(string: "/courses/42/modules")!,
            full_url: URL(string: "/courses/42/pages")!,
            url: URL(string: "/courses/42/stuff")!
        )
        let tab: Tab = databaseClient.insert()
        tab.save(apiTab, in: databaseClient, context: .course("42"))
        drainMainQueue()

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/modules")), true)

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/users")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/pages")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/stuff")), false)
    }

    func test_setupEnabledTabs_whenTabIsNotCourseOrGroup_shouldIgnore() {
        saveTab(htmlUrl: "/accounts/42/not-pages", context: .account("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/accounts/42/pages")), true)
    }

    func test_setupEnabledTabs_whenSyllabusIsEnabled_shouldEnableAlternativePaths() {
        saveTab(id: "syllabus", htmlUrl: "/courses/42/_something_", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/syllabus")), true)
    }

    func test_setupEnabledTabs_whenDiscussionsIsEnabled_shouldEnableAlternativePaths() {
        saveTab(id: "discussions", htmlUrl: "/courses/42/_something_", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/discussions")), true)
    }

    func test_setupEnabledTabs_whenPagesIsEnabled_shouldEnableAlternativePaths() {
        saveTab(id: "pages", htmlUrl: "/courses/42/_something_", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/pages")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/pages/front_page")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/front_page")), true)
    }

    // MARK: - Log unknown formats

    func test_setupEnabledTabs_whenPathFormatIsUnknown_shouldLogIt() {
        // known path formats are not logged
        saveTab(id: "stuff", htmlUrl: "/courses/42/stuff", context: .course("42"))
        saveTab(id: "syllabus", htmlUrl: "/courses/42/assignments/syllabus", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, nil)

        // unknown path format is logged
        saveTab(id: "pages", htmlUrl: "/courses/42/tabs/stuff", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, "Unexpected Course Tab path format")
    }

    func test_setupEnabledTabs_whenTabIsHomeOrHasHomeFormat_shouldNotLogIt() {
        // `id: home` is not logged
        saveTab(id: "home", htmlUrl: "/courses/42/ignoring/this/url", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, nil)

        // home-like format with different id is not logged
        saveTab(id: "schedule", htmlUrl: "/courses/42", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, nil)
    }

    func test_setupEnabledTabs_whenTabIsSettings_shouldNotLogIt() {
        saveTab(id: "settings", htmlUrl: "/courses/42/settings", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, nil)
    }

    func test_setupEnabledTabs_whenTabHasLTILaunchRequestFormat_shouldNotLogIt() {
        saveTab(id: "someId", htmlUrl: "/courses/42/lti/basic_lti_launch_request/123", context: .course("42"))
        saveTab(id: "someId", htmlUrl: "/courses/42/lti/basic_lti_launch_request/123?resource_link_fragment=nav", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, nil)
    }

    // MARK: - Cancel subscription

    func test_cancelTabSubscription_shouldNotReactToTabObjectChanges() {
        saveTab(htmlUrl: "/courses/42/users", context: .course("42"))

        testee.cancelTabSubscription()

        saveTab(htmlUrl: "/courses/42/pages", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/users")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/pages")), false)
    }

    // MARK: - Clear tabs

    func test_clearEnabledTabs_shouldAllowAll() {
        saveTab(htmlUrl: "/courses/42/users", context: .course("42"))

        testee.clearEnabledTabs()

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/users")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/pages")), true)
        verifyUnrelatedURLsAreAllowed()
    }

    func test_clearEnabledTabs_shouldNotRemoveTabsFromDatabase() {
        saveTab(id: "people", htmlUrl: "/courses/42/users", context: .course("42"))

        testee.clearEnabledTabs()

        let tabs: [Tab] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(tabs.first?.id, "people")

        saveTab(htmlUrl: "/courses/42/pages", context: .course("42"))
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/users")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/pages")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/modules")), false)
        verifyUnrelatedURLsAreAllowed()
    }

    // MARK: - Host Overrides

    func test_baseURlHostOverrides() {
        saveTab(
            id: "12345~324",
            htmlUrl: "/courses/324/pages",
            fullUrl: "https://example-01.instructure.com/courses/324/pages",
            context: .course("324")
        )
        saveTab(
            id: "01234~123",
            htmlUrl: "/courses/123/pages",
            fullUrl: "https://example-02.instructure.com/courses/324/pages",
            context: .course("123")
        )
        saveTab(
            id: "54321~435",
            htmlUrl: "/courses/435/pages",
            fullUrl: "https://example-03.instructure.com/courses/324/pages",
            context: .course("435")
        )
        saveTab(
            id: "324",
            htmlUrl: "/courses/324/pages",
            fullUrl: "https://example-01.instructure.com/courses/324/pages",
            context: .course("324")
        )

        XCTAssertEqual(
            testee.baseURLHostOverrides,
            Set(["example-01.instructure.com", "example-02.instructure.com", "example-03.instructure.com"])
        )

        XCTAssertEqual(
            testee.baseUrlHostOverride(for: .init(string: "/courses/324/pages")!),
            "example-01.instructure.com"
        )

        XCTAssertEqual(
            testee.baseUrlHostOverride(for: .init(string: "/courses/123/pages")!),
            "example-02.instructure.com"
        )

        XCTAssertEqual(
            testee.baseUrlHostOverride(for: .init(string: "/courses/435/pages")!),
            "example-03.instructure.com"
        )
    }

    // MARK: - Course Shard ID

    func test_contextShardID() {
        saveTab(
            id: "324",
            htmlUrl: "/courses/324/pages",
            fullUrl: "https://example-01.instructure.com/courses/324/pages",
            context: .course("12345~324")
        )
        saveTab(
            id: "123",
            htmlUrl: "/courses/123/pages",
            fullUrl: "https://example-02.instructure.com/courses/123/pages",
            context: .course("7643~123")
        )
        saveTab(
            id: "435",
            htmlUrl: "/courses/435/pages",
            fullUrl: "https://example-03.instructure.com/courses/435/pages",
            context: .course("54321~435")
        )
        saveTab(
            id: "324",
            htmlUrl: "/courses/324/pages",
            fullUrl: "https://example-01.instructure.com/courses/324/pages",
            context: .course("324")
        )

        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/324/pages")!), "12345")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/123/grades")!), "7643")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/435/people")!), "54321")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/98762~678/pages")!), "98762")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "https://example-03.instructure.com/pages/897")!), "54321")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/324/assignments")!), "12345")

        XCTAssertNil(testee.contextShardID(for: .init(string: "/courses/786/pages")!))
    }

    // MARK: - Private helpers

    @discardableResult
    private func saveTab(id: String = "", htmlUrl: String, fullUrl: String? = nil, context: Context) -> Tab {
        let fURL = fullUrl.flatMap({ URL(string: $0) })
        let apiTab = APITab.make(id: ID(id), html_url: URL(string: htmlUrl)!, full_url: fURL)
        let tab: Tab = databaseClient.insert()
        tab.save(apiTab, in: databaseClient, context: context)
        drainMainQueue()
        return tab
    }

    private func verifyUnrelatedURLsAreAllowed() {
        XCTAssertEqual(testee.isAllowedUrl(.make("/users/self/activity_stream")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/login/session_token")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("https://instructure.com")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("stuff")), true)
    }
}

private extension URL {
    static func make(_ string: String) -> URL {
        URL(string: string)!
    }
}

private extension ContextTabUrlInteractor {
    func isAllowedUrl(_ url: URL) -> Bool {
        isAllowedUrl(url, userInfo: nil)
    }
}
