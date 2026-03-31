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

#if DEBUG
import Combine
import Foundation

final class GetLearnCoursesInteractorPreview: GetLearnCoursesInteractor {
    func getFirstCourse(ignoreCache: Bool) -> AnyPublisher<LearnCourse?, any Error> {
        Just(LearnCourse(id: "ID", name: "Canvas Preview", enrollmentId: "enrollmentId"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getCourses(ignoreCache: Bool) -> AnyPublisher<[LearnCourse], Never> {
        Just(
            [
                LearnCourse(id: "ID-1", name: "Canvas Preview - 1", enrollmentId: "enrollmentId - 1"),
                LearnCourse(id: "ID-2", name: "Canvas Preview - 2", enrollmentId: "enrollmentId - 2"),
                LearnCourse(id: "ID-3", name: "Canvas Preview - 2", enrollmentId: "enrollmentId - 3")
            ]
        )
        .eraseToAnyPublisher()
    }
}
#endif
