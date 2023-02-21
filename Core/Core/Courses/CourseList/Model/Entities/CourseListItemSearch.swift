//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public extension Array where Element == CourseListItem {

    func filter(query: String) -> Future<[CourseListItem], Never> {
        Future<[CourseListItem], Never> { promise in
            if query.isEmpty {
                return promise(.success(self))
            }

            let filteredItems = filter {
                $0.name.lowercased().contains(query) || $0.courseCode.lowercased().contains(query)
            }
            promise(.success(filteredItems))
        }
    }
}

public extension Publisher where Output == [CourseListItem], Failure == Never {

    func filter<Query: Publisher>(with query: Query) -> AnyPublisher<Output, Failure>
        where Query.Output == String, Query.Failure == Failure {
        Publishers
            .CombineLatest(self, query.map { $0.lowercased() })
            .flatMap { (items, searchQuery) in
                items.filter(query: searchQuery)
            }
            .eraseToAnyPublisher()
    }
}
