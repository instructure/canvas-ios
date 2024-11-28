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

final class CourseTabUrlInteractorTests: CoreTestCase {

    private var testee: CourseTabUrlInteractor!

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

        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/api/v1/courses/42/discussion_topics?per_page=100&include%5B%5D=sections&no_verifiers=1")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/42/discussion_topics")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/discussion_topics")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/unkown_thing")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/1234")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/1234/")), true)

        verifyUnrelatedURLsAreAllowed()
    }

    // MARK: - Enabled / Disabled tabs

    func test_isAllowedUrl_whenSetupWithTabs_shouldAllowOnlyEnabledTabs() {
        saveTab(htmlUrl: "/courses/42/grades", context: .course("42"))
        saveTab(htmlUrl: "/courses/42/users", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/grades")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/users")), true)

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/modules")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/unkown_thing")), false)

        verifyUnrelatedURLsAreAllowed()
    }

    func test_isAllowedUrl_whenUrlIsNotCourseTab_shouldAllow() {
        saveTab(htmlUrl: "/courses/42/_something_", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/groups/42/grades")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/users/42/settings")), true)
    }

    func test_isAllowedUrl_whenTabIsDisabledInAnotherCourse_shouldBlockOnlyForThatCourse() {
        saveTab(htmlUrl: "/courses/7/not_grades", context: .course("7"))
        saveTab(htmlUrl: "/courses/42/grades", context: .course("42"))

        // tab disabled in course -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/7/grades")), false)

        // tab enabled in course -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/grades")), true)

        // tab in unknown course -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/0/grades")), true)
    }

    // MARK: - Tab Format rules

    func test_isAllowedUrl_whenTabIsDisabled_shouldBlockAllVariants() {
        saveTab(htmlUrl: "/courses/42/not_grades", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("https://stuff.instructure.com/api/v1/courses/42/grades?per_page=100&include%5B%5D=sections&no_verifiers=1")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/api/v1/courses/42/grades")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/grades")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/grades/")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("courses/42/grades")), false)
    }

    func test_isAllowedUrl_whenTabIsDisabled_shouldAllowSubpages() {
        saveTab(htmlUrl: "/courses/42/not_grades", context: .course("42"))

        // subpage -> allow
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/grades/123")), true)

        // tab -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/grades")), false)
    }

    func test_isAllowedUrl_whenTabIsDisabled_shouldAllowInternalNavigationPaths() {
        saveTab(htmlUrl: "/courses/42/_something_", context: .course("42"))

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/tabs")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/activity_stream")), true)
        XCTAssertEqual(testee.isAllowedUrl(.make("/users/42/activity_stream")), true)
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

    func test_isAllowedUrl_whenExternalToolsIsDisabled_shouldBlockExternalToolsUrlFormat() {
        saveTab(htmlUrl: "/courses/42/not_external_tools", context: .course("42"))

        // matching special format -> block
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools/1234")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools/something")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/external_tools/syllabus")), false)

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
            url: URL(string: "/courses/42/grades")!
        )
        let tab: Tab = databaseClient.insert()
        tab.save(apiTab, in: databaseClient, context: .course("42"))
        drainMainQueue()

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/modules")), true)

        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/users")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/pages")), false)
        XCTAssertEqual(testee.isAllowedUrl(.make("/courses/42/grades")), false)
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

    func test_setupEnabledTabs_whenPathFormatIsUnknown_shouldLogIt() {
        // known path formats are not logged
        saveTab(id: "grades", htmlUrl: "/courses/42/grades", context: .course("42"))
        saveTab(id: "syllabus", htmlUrl: "/courses/42/assignments/syllabus", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, nil)

        // unknown path format is logged
        saveTab(id: "pages", htmlUrl: "/courses/42/tabs/grades", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, "Unexpected Course Tab path format")
    }

    func test_setupEnabledTabs_whenTabIsHome_shouldNotLogIt() {
        // `id: home` is not logged
        saveTab(id: "home", htmlUrl: "/courses/42/ignoring/this/url", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, nil)

        // home-like format with different id is logged
        saveTab(id: "pages", htmlUrl: "/courses/42", context: .course("42"))
        XCTAssertEqual(remoteLogHandler.lastErrorName, "Unexpected Course Tab path format")
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

    // MARK: - Private helpers

    @discardableResult
    private func saveTab(id: String = "", htmlUrl: String, context: Context) -> Tab {
        let apiTab = APITab.make(id: ID(id), html_url: URL(string: htmlUrl)!)
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
