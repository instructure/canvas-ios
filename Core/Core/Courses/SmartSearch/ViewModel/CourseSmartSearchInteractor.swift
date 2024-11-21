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

import Foundation
import Combine

public protocol CourseSmartSearchInteractor: SearchInteractor {
    var isEnabled: AnyPublisher<Bool, Never> { get }
    func fetchCourse() -> AnyPublisher<Course?, Never>

    func search(
        for searchTerm: String,
        filter: CourseSmartSearchFilter?
    ) -> AnyPublisher<[CourseSmartSearchResult], Never>
}

class CourseSmartSearchInteractorLive: CourseSmartSearchInteractor {

    private lazy var flagsStore = ReactiveStore(useCase: GetEnabledFeatureFlags(context: context))
    private lazy var courseStore: ReactiveStore<GetCourse>? = {
        guard let courseId = context.courseId else { return nil }
        return ReactiveStore(useCase: GetCourse(courseID: courseId))
    }()

    private lazy var resultsCollection = FetchedCollection(
        ofRequest: CourseSmartSearchRequest.self,
        transform: {
            $0.results
                .sorted(by: CourseSmartSearchResult.sortStrategy)
                .filter({ $0.relevance >= 50 })
        }
    )

    let context: Context
    init(context: Context) {
        self.context = context
    }

    var isEnabled: AnyPublisher<Bool, Never> {
        flagsStore
            .getEntities(ignoreCache: true)
            .replaceError(with: [])
            .map({ $0.contains(where: { $0.name == "smart_search" }) })
            .eraseToAnyPublisher()
    }

    func fetchCourse() -> AnyPublisher<Course?, Never> {
        guard let store = courseStore else {
            return Just(nil).eraseToAnyPublisher()
        }

        return store
            .getEntities()
            .replaceError(with: [])
            .map({ $0.first })
            .eraseToAnyPublisher()
    }

    func search(
        for searchTerm: String,
        filter: CourseSmartSearchFilter?
    ) -> AnyPublisher<[CourseSmartSearchResult], Never> {

        guard let courseId = context.courseId else {
            return Just([]).eraseToAnyPublisher()
        }

        return resultsCollection
            .fetch(
                CourseSmartSearchRequest(
                    courseId: courseId,
                    searchText: searchTerm,
                    filter: filter?.includedTypes.map({ $0.filterValue })
                )
            )
    }
}

extension CourseSmartSearchResult {
    static let sortStrategy: (CourseSmartSearchResult, CourseSmartSearchResult) -> Bool = { (result1, result2) in
        // First: Sort on relevance
        // Ideally, API should be returning results sorted according to relevance,
        // This is to double check on this, in addition to unit testing.
        if result1.relevance != result2.relevance {
            return result1.relevance > result2.relevance
        }

        // Then: Sort on alphabetical order
        return result1.title < result2.title
    }
}

#if DEBUG

class CourseSmartSearchInteractorPreview: CourseSmartSearchInteractor {

    var enabledValue: Bool = false
    var isEnabled: AnyPublisher<Bool, Never> {
        Just(enabledValue).eraseToAnyPublisher()
    }

    var courseValue: Course?
    func fetchCourse() -> AnyPublisher<Course?, Never> {
        Just(courseValue).eraseToAnyPublisher()
    }

    var results: [CourseSmartSearchResult] = []
    func search(for searchTerm: String, filter: CourseSmartSearchFilter?) -> AnyPublisher<[CourseSmartSearchResult], Never> {
        Just(results).eraseToAnyPublisher()
    }
}

#endif
