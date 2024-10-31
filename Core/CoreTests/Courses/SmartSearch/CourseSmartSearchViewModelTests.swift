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
@testable import Core

final class CourseSmartSearchViewModelTests: CoreTestCase {

    enum TestConstants {
        static let courseId: String = "demo_course_id"
        static let color: UIColor = .red
        static var context: Context { Context(.course, id: courseId) }
        static var info: CourseSmartSearch { CourseSmartSearch(context: context, color: color) }
        static var searchContext: CoreSearchContext<CourseSmartSearch> { .init(info: info) }

        static var results: [CourseSmartSearchResult] = [
            .make(type: .page),
            .make(type: .page),
            .make(type: .assignment),
            .make(type: .assignment),
            .make(type: .announcement),
            .make(type: .discussion),
            .make(type: .discussion)
        ]
    }

    private var interactor: CourseSmartSearchInteractor!

    override func setUp() {
        super.setUp()
        API.resetMocks()
        interactor = CourseSmartSearchInteractorLive()
    }

    override func tearDown() {
        interactor = nil
        super.tearDown()
    }

    func test_searching_results() throws {
        // Given
        let searchWord = "Demo Search"

        let mockRequest = api.mock(
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
        mockRequest.suspend()

        // When
        let model = CourseSmartSearchViewModel(
            context: TestConstants.context,
            interactor: interactor
        )

        // Then
        XCTAssertEqual(model.phase, .start)

        // When
        model.startSearch(of: searchWord)
        // Then
        XCTAssertEqual(model.phase, .loading)

        // When
        mockRequest.resume()
        drainMainQueue()

        // Then
        XCTAssertEqual(model.results, TestConstants.results.sorted(by: CourseSmartSearchResult.sortStrategy))
    }

    func test_searching_no_match() throws {
        // Given
        let searchWord = "Search Nothing"

        let mockRequest = api.mock(
            CourseSmartSearchRequest(
                courseId: TestConstants.courseId,
                searchText: searchWord,
                filter: nil
            ),
            value: nil
        )
        mockRequest.suspend()

        // When
        let model = CourseSmartSearchViewModel(
            context: TestConstants.context,
            interactor: interactor
        )
        // Then
        XCTAssertEqual(model.phase, .start)

        // When
        model.startSearch(of: searchWord)
        // Then
        XCTAssertEqual(model.phase, .loading)

        // When
        mockRequest.resume()
        drainMainQueue()

        // Then
        XCTAssertEqual(model.phase, .noMatch)
        XCTAssertEqual(model.results, [])
    }

    func test_course_fetch() throws {
        // Given
        let courseID = ID(TestConstants.courseId)
        let apiCourse = APICourse.make(id: courseID, name: "Random Course Name")
        api.mock(GetCourse(courseID: TestConstants.courseId), value: apiCourse)

        // When
        let model = CourseSmartSearchViewModel(
            context: TestConstants.context,
            interactor: interactor
        )

        // When
        model.fetchCourse()
        drainMainQueue()

        // Then
        let course: Course = try XCTUnwrap(model.course)
        XCTAssertEqual(course.id, apiCourse.id.rawValue)
        XCTAssertEqual(course.name, apiCourse.name)
    }

    func test_searching_filtered() throws {
        // Given
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
        let model = CourseSmartSearchViewModel(
            context: TestConstants.context,
            interactor: interactor
        )
        model.filter = filter
        model.startSearch(of: searchWord)
        drainMainQueue()

        // Then
        let sortedTypes = filterTypes.sorted(by: { $0.sortOrder < $1.sortOrder })
        XCTAssertEqual(model.phase, .groupedResults)
        XCTAssertEqual(model.sectionedResults.map { $0.type }, sortedTypes)
    }
}

extension CourseSmartSearchResult {
    static func make(type: ContentType? = nil) -> CourseSmartSearchResult {
        let cType = type ?? ContentType.allCases.randomElement() ?? .page
        return CourseSmartSearchResult(
            content_id: .init(integerLiteral: Int.random(in: 1000 ... 7000)),
            content_type: cType,
            readable_type: cType.title,
            title: "\(cType.title) title",
            body: "Search result body",
            html_url: URL(string: "https://www.google.com"),
            distance: Double.random(in: 0.3 ... 0.99),
            relevance: Int.random(in: 40 ... 95)
        )
    }
}
