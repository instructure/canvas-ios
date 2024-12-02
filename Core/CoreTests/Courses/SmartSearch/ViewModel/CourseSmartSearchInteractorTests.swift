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

import Combine
import TestsFoundation
@testable import Core
import XCTest

class CourseSmartSearchInteractorTests: CoreTestCase {

    enum TestConstants {
        static let courseID: String = "demo_course_id"
        static var context: Context { Context(.course, id: courseID) }

        static var results: [CourseSmartSearchResult] = [
            .make(type: .page),
            .make(type: .page),
            .make(type: .assignment),
            .make(type: .assignment),
            .make(type: .announcement),
            .make(type: .discussion),
            .make(type: .discussion)
        ]

        static var expected: [CourseSmartSearchResult] = {
            return results
                .sorted(by: CourseSmartSearchResult.sortStrategy)
                .filter({ $0.relevance >= 50 })
        }()
    }

    private var subscriptions = Set<AnyCancellable>()
    private var interactor: CourseSmartSearchInteractorLive!

    override func setUp() {
        super.setUp()
        interactor = CourseSmartSearchInteractorLive(courseID: TestConstants.courseID)
    }

    override func tearDown() {
        subscriptions.removeAll()
        interactor = nil
        super.tearDown()
    }

    func enablementGiven(flags: [String], tabs: [TabName]) {
        let context = TestConstants.context
        let flagsUseCase = GetEnabledFeatureFlags(context: TestConstants.context)

        api.mock(flagsUseCase, value: flags)

        for tab in tabs {
            Tab.make(
                from: .make(id: .init(tab.rawValue)),
                context: context,
                in: databaseClient)
        }
    }

    func test_enablement_all_enabled() throws {
        // When
        enablementGiven(
            flags: ["smart_search", "dummy_flag_2"],
            tabs: [.announcements, .search]
        )

        // Then
        interactor
            .isEnabled
            .sink { enabled in
                XCTAssertTrue(enabled)
            }
            .store(in: &subscriptions)
    }

    func test_enablement_flag_enabled() throws {
        // When
        enablementGiven(
            flags: ["smart_search"],
            tabs: [.announcements, .pages]
        )

        // Then
        interactor
            .isEnabled
            .sink { enabled in
                XCTAssertFalse(enabled)
            }
            .store(in: &subscriptions)
    }

    func test_enablement_tab_enabled() throws {
        // When
        enablementGiven(
            flags: ["dummy_flag_2"],
            tabs: [.announcements, .search]
        )

        // Then
        interactor
            .isEnabled
            .sink { enabled in
                XCTAssertFalse(enabled)
            }
            .store(in: &subscriptions)
    }

    func test_enablement_none_enabled() throws {
        // When
        enablementGiven(
            flags: ["dummy_flag_2"],
            tabs: [.announcements, .pages]
        )

        // Then
        interactor
            .isEnabled
            .sink { enabled in
                XCTAssertFalse(enabled)
            }
            .store(in: &subscriptions)
    }

    func test_searching_results() throws {
        // Given
        let searchWord = "Demo Search"

        api.mock(
            CourseSmartSearchRequest(
                courseId: TestConstants.courseID,
                searchText: searchWord,
                filter: nil
            ),
            value: APICourseSmartSearchResponse(
                results: TestConstants.results,
                status: nil,
                indexing_progress: nil
            )
        )

        // When
        let results = interactor.search(for: searchWord, filter: nil)

        // Then
        XCTAssertSingleOutputEquals(results, TestConstants.expected)
    }

    func test_searching_with_filter() throws {
        // Given
        let searchWord = "Filtered Search"

        let filterTypes: [CourseSmartSearchResultType] = [.announcement, .assignment]
        let filter = CourseSmartSearchFilter(sortMode: .type, includedTypes: filterTypes)

        api.mock(
            CourseSmartSearchRequest(
                courseId: TestConstants.courseID,
                searchText: searchWord,
                filter: filter.includedTypes.map({ $0.filterValue })
            ),
            value: APICourseSmartSearchResponse(
                results: TestConstants.results,
                status: nil,
                indexing_progress: nil
            )
        )

        // When
        let results = interactor.search(for: searchWord, filter: filter)

        // Then
        XCTAssertSingleOutputEquals(results, TestConstants.expected)
    }

    func test_course_fetch() throws {
        // Given
        let courseID = ID(TestConstants.courseID)
        let apiCourse = APICourse.make(id: courseID, name: "Random Course Name")
        api.mock(GetCourse(courseID: TestConstants.courseID), value: apiCourse)

        // When
        let courseFetcher = interactor.fetchCourse()

        // Then
        XCTAssertFirstValue(courseFetcher) { fetched in
            guard let course = fetched else {
                return XCTFail("No course was fetched!")
            }

            XCTAssertEqual(course.id, apiCourse.id.rawValue)
            XCTAssertEqual(course.name, apiCourse.name)
        }
    }
}
