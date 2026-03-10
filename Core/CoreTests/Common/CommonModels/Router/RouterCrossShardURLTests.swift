//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

class RouterCrossShardURLTests: RouterInteractorTestCase {

    private var contextBaseUrlInteractor: ContextBaseUrlInteractor!

    override func setUp() {
        super.setUp()
        contextBaseUrlInteractor = .init()
        contextBaseUrlInteractor.setupTabSubscription()
    }

    override func tearDown() {
        contextBaseUrlInteractor = nil
        super.tearDown()
    }

    // MARK: - Course file

    func test_match_whenCrossShardCourseFileURL_shouldTransformFileIDToLocalForm() {
        saveTab(
            htmlUrl: "/courses/324/files",
            fullUrl: "https://shard-02.instructure.com/courses/324/files",
            context: .course("12345~324")
        )

        var capturedURL: URLComponents?
        let router = Router(
            routes: [
                RouteHandler("/courses/:courseID/files/:fileID") { url, _, _ in
                    capturedURL = url
                    return nil
                }
            ],
            contextBaseUrlInteractor: contextBaseUrlInteractor
        )

        _ = router.match(URLComponents(string: "/courses/12345~324/files/12345~567")!)

        XCTAssertEqual(capturedURL?.path, "/courses/12345~324/files/567")
    }

    // MARK: - Group item

    func test_match_whenCrossShardGroupItemURL_shouldTransformItemIDToLocalForm() {
        saveTab(
            htmlUrl: "/groups/843/assignments",
            fullUrl: "https://shard-04.instructure.com/groups/843/assignments",
            context: .group("23456~843")
        )

        var capturedURL: URLComponents?
        let router = Router(
            routes: [
                RouteHandler("/groups/:groupID/assignments/:assignmentID") { url, _, _ in
                    capturedURL = url
                    return nil
                }
            ],
            contextBaseUrlInteractor: contextBaseUrlInteractor
        )

        _ = router.match(URLComponents(string: "/groups/23456~843/assignments/23456~111")!)

        XCTAssertEqual(capturedURL?.path, "/groups/23456~843/assignments/111")
    }

    // MARK: - Shard mismatch

    func test_match_whenItemShardDiffersFromContextShard_shouldNotTransformItemID() {
        saveTab(
            htmlUrl: "/courses/324/files",
            fullUrl: "https://shard-02.instructure.com/courses/324/files",
            context: .course("12345~324")
        )

        var capturedURL: URLComponents?
        let router = Router(
            routes: [
                RouteHandler("/courses/:courseID/files/:fileID") { url, _, _ in
                    capturedURL = url
                    return nil
                }
            ],
            contextBaseUrlInteractor: contextBaseUrlInteractor
        )

        _ = router.match(URLComponents(string: "/courses/12345~324/files/99999~567")!)

        XCTAssertEqual(capturedURL?.path, "/courses/12345~324/files/99999~567")
    }

    // MARK: - No host override

    func test_match_whenNoHostOverride_shouldNotTransformIDs() {
        var capturedURL: URLComponents?
        let router = Router(
            routes: [
                RouteHandler("/courses/:courseID/files/:fileID") { url, _, _ in
                    capturedURL = url
                    return nil
                }
            ],
            contextBaseUrlInteractor: contextBaseUrlInteractor
        )

        _ = router.match(URLComponents(string: "/courses/12345~324/files/12345~567")!)

        XCTAssertEqual(capturedURL?.path, "/courses/12345~324/files/12345~567")
    }
}
