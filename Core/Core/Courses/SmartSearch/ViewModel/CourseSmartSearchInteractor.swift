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

public protocol CourseSmartSearchInteractor {

    func isEnabled(context: Context) -> AnyPublisher<Bool, Never>

    func fetchCourse(context: Context) -> AnyPublisher<Course?, Never>

    func startSearch(
        in context: Context,
        of searchTerm: String,
        filter: CourseSmartSearchFilter?
    ) -> AnyPublisher<[CourseSmartSearchResult], Never>
}

class CourseSmartSearchInteractorLive: CourseSmartSearchInteractor {

    func isEnabled(context: Context) -> AnyPublisher<Bool, Never> {
        return ReactiveStore(useCase: GetEnabledFeatureFlags(context: context))
            .getEntities()
            .replaceError(with: [])
            .map({ $0.contains(where: { $0.name == "smart_search" }) })
            .eraseToAnyPublisher()
    }

    func fetchCourse(context: Context) -> AnyPublisher<Course?, Never> {
        guard let courseId = context.courseId else {
            return Just(nil).eraseToAnyPublisher()
        }

        return ReactiveStore(useCase: GetCourse(courseID: courseId))
            .getEntities()
            .replaceError(with: [])
            .map({ list in
                print(list)
                return list.first
            })
            .eraseToAnyPublisher()
    }

    func startSearch(
        in context: Context,
        of searchTerm: String,
        filter: CourseSmartSearchFilter?
    ) -> AnyPublisher<[CourseSmartSearchResult], Never> {

        guard let courseId = context.courseId else {
            return Just([]).eraseToAnyPublisher()
        }

        return AppEnvironment
            .shared
            .api
            .makeRequest(
                CourseSmartSearchRequest(
                    courseId: courseId,
                    searchText: searchTerm,
                    filter: filter?.includedTypes.map({ $0.filterValue })
                )
            )
            .map({ $0.body.results.sorted(by: CourseSmartSearchResult.sortStrategy) })
            .replaceError(with: [])
            .eraseToAnyPublisher()
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
    func isEnabled(context: Context) -> AnyPublisher<Bool, Never> {
        Just(enabledValue).eraseToAnyPublisher()
    }

    var courseValue: Course?
    func fetchCourse(context: Context) -> AnyPublisher<Course?, Never> {
        Just(courseValue).eraseToAnyPublisher()
    }

    var results: [CourseSmartSearchResult] = []
    func startSearch(in context: Context, of searchTerm: String, filter: CourseSmartSearchFilter?) -> AnyPublisher<[CourseSmartSearchResult], Never> {
        Just(results).eraseToAnyPublisher()
    }
}

#endif
