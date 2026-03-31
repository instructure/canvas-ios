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

import Combine
@testable import Horizon
import Foundation

final class GetCoursesInteractorMock: GetCoursesInteractor {
    var shouldFail = false
    var error: Error = URLError(.badServerResponse)
    var coursesToReturn: [HCourse] = []
    var syllabusToReturn: String?

    func getCourseWithModules(id: String, ignoreCache: Bool) -> AnyPublisher<HCourse?, Never> {
        guard !shouldFail else {
            return Just(nil).eraseToAnyPublisher()
        }

        let course = coursesToReturn.first { $0.id == id }
        return Just(course).eraseToAnyPublisher()
    }

    func getCoursesWithoutModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        guard !shouldFail else {
            return Just([]).eraseToAnyPublisher()
        }

        return Just(coursesToReturn).eraseToAnyPublisher()
    }

    func getCourseSyllabus(courseID: String, ignoreCache: Bool) -> AnyPublisher<String?, Never> {
        guard !shouldFail else {
            return Just(nil).eraseToAnyPublisher()
        }

        return Just(syllabusToReturn).eraseToAnyPublisher()
    }
}
