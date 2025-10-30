//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

final class ContextBaseUrlInteractorTests: RouterInteractorTestCase {

    private var testee: ContextBaseUrlInteractor!

    override func setUp() {
        super.setUp()
        testee = .init()
        testee.setupTabSubscription()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
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
            htmlUrl: "/courses/123/assignments",
            fullUrl: "https://example-02.instructure.com/courses/123/assignments",
            context: .course("123")
        )
        saveTab(
            id: "54321~435",
            htmlUrl: "/courses/435/files",
            fullUrl: "https://example-03.instructure.com/courses/435/files",
            context: .course("435")
        )
        saveTab(
            id: "324",
            htmlUrl: "/courses/324/pages",
            fullUrl: "https://example-01.instructure.com/courses/324/pages",
            context: .course("324")
        )

        saveTab(
            id: "8667~435",
            htmlUrl: "/groups/889/grades",
            fullUrl: "https://example-03.instructure.com/groups/889/grades",
            context: .group("889")
        )
        saveTab(
            id: "989",
            htmlUrl: "/groups/234/files",
            fullUrl: "https://example-01.instructure.com/groups/234/files",
            context: .group("234")
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
            testee.baseUrlHostOverride(for: .init(string: "/courses/123/assignments")!),
            "example-02.instructure.com"
        )

        XCTAssertEqual(
            testee.baseUrlHostOverride(for: .init(string: "/courses/435/files")!),
            "example-03.instructure.com"
        )

        XCTAssertEqual(
            testee.baseUrlHostOverride(for: .init(string: "/groups/889/grades")!),
            "example-03.instructure.com"
        )

        XCTAssertEqual(
            testee.baseUrlHostOverride(for: .init(string: "/groups/234/files")!),
            "example-01.instructure.com"
        )
    }

    // MARK: - Course & Group Shard ID

    func test_contextShardID() {
        saveTab(
            id: "765",
            htmlUrl: "/courses/324/discussion_topics",
            fullUrl: "https://example-01.instructure.com/courses/324/discussion_topics",
            context: .course("12345~324")
        )
        saveTab(
            id: "123",
            htmlUrl: "/courses/123/pages",
            fullUrl: "https://example-02.instructure.com/courses/123/pages",
            context: .course("7643~123")
        )
        saveTab(
            id: "987",
            htmlUrl: "/courses/435/people",
            fullUrl: "https://example-03.instructure.com/courses/435/people",
            context: .course("54321~435")
        )
        saveTab(
            id: "111",
            htmlUrl: "/groups/843/pages",
            fullUrl: "https://example-04.instructure.com/groups/843/pages",
            context: .group("23456~843")
        )
        saveTab(
            id: "324",
            htmlUrl: "/courses/324/pages",
            fullUrl: "https://example-01.instructure.com/courses/324/pages",
            context: .course("324")
        )

        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/324/discussion_topics")!), "12345")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/123/grades")!), "7643")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/435/people")!), "54321")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/98762~678/pages")!), "98762")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "https://example-03.instructure.com/courses/435/people")!), "54321")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/groups/843/pages")!), "23456")
        XCTAssertEqual(testee.contextShardID(for: .init(string: "/courses/324/assignments")!), "12345")

        XCTAssertNil(testee.contextShardID(for: .init(string: "/courses/786/pages")!))
    }
}
