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
        static let courseId: String = "demo_course_id"
        static var context: Context { Context(.course, id: courseId) }

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

    func test_enablement() throws {
        // Given
        let context = TestConstants.context
        let useCase = GetEnabledFeatureFlags(context: context)

        // When
        api.mock(useCase, value: [
            "smart_search",
            "dummy_flag_2"
        ])

        // When
        let interactor = CourseSmartSearchInteractorLive(context: context)

        // Then
        XCTAssertSingleOutputEquals(interactor.isEnabled(), true)

        // When
        useCase.reset(context: databaseClient)
        api.mock(useCase, value: [
            "dummy_flag_2"
        ])

        // Then
        XCTAssertSingleOutputEquals(interactor.isEnabled(), false)
    }

    func test_searching_results() throws {
        // Given
        let searchWord = "Demo Search"
        let interactor = CourseSmartSearchInteractorLive(context: TestConstants.context)

        api.mock(
            CourseSmartSearchRequest(
                courseId: TestConstants.courseId,
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
        let interactor = CourseSmartSearchInteractorLive(context: TestConstants.context)
        let searchWord = "Filtered Search"

        let filterTypes: [CourseSmartSearchResultType] = [.announcement, .assignment]
        let filter = CourseSmartSearchFilter(sortMode: .type, includedTypes: filterTypes)

        api.mock(
            CourseSmartSearchRequest(
                courseId: TestConstants.courseId,
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
        let interactor = CourseSmartSearchInteractorLive(context: TestConstants.context)

        let courseID = ID(TestConstants.courseId)
        let apiCourse = APICourse.make(id: courseID, name: "Random Course Name")
        api.mock(GetCourse(courseID: TestConstants.courseId), value: apiCourse)

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
