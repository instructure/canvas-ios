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

    private lazy var flagsStore = ReactiveStore(
        useCase: GetEnabledFeatureFlags(context: .course(courseID))
    )

    private lazy var courseStore = ReactiveStore(useCase: GetCourse(courseID: courseID))

    private lazy var tabsStore = ReactiveStore(
        useCase: GetContextTabs(context: .course(courseID))
    )

    private lazy var resultsCollection = FetchedCollection(
        ofRequest: CourseSmartSearchRequest.self,
        transform: {
            $0.results
                .sorted(by: CourseSmartSearchResult.sortStrategy)
                .filter({ $0.relevance >= 50 })
        }
    )

    private let courseID: String

    init(courseID: String) {
        self.courseID = courseID
    }

    var isEnabled: AnyPublisher<Bool, Never> {
        let isFeatureFlagEnabled = flagsStore
            .getEntities(ignoreCache: true)
            .replaceError(with: [])
            .map { flags in
                flags.contains(where: { $0.name == "smart_search" })
            }

        let isTabEnabled = tabsStore
            .getEntities(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .map { tabs in
                tabs.contains(where: { $0.name == .search })
            }

        return Publishers
            .CombineLatest(isFeatureFlagEnabled, isTabEnabled)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }

    func fetchCourse() -> AnyPublisher<Course?, Never> {
        return courseStore
            .getEntities()
            .replaceError(with: [])
            .map({ $0.first })
            .eraseToAnyPublisher()
    }

    func search(
        for searchTerm: String,
        filter: CourseSmartSearchFilter?
    ) -> AnyPublisher<[CourseSmartSearchResult], Never> {
        return resultsCollection
            .fetch(
                CourseSmartSearchRequest(
                    courseId: courseID,
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
