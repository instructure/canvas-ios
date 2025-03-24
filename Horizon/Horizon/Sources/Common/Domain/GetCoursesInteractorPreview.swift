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

#if DEBUG
import Combine
import Foundation
import Core

class GetCoursesInteractorPreview: GetCoursesInteractor {
    func getNextUpModuleItems(ignoreCache: Bool) -> AnyPublisher<[NextUpViewModel], Never> {
        Just(
            [.init(
                name: "AI Introductions",
                progress: 0.2,
                learningObjectCardViewModel: nil
            )
            ]
        )
        .eraseToAnyPublisher()
    }

    func getInstitutionName() -> AnyPublisher<String, Never> {
        Just("Canvas Career")
            .eraseToAnyPublisher()
    }

    func getCourses(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        Just([course])
            .eraseToAnyPublisher()
    }

    func getCourse(id: String, ignoreCache: Bool) -> AnyPublisher<HCourse?, Never> {
        Just(course)
            .eraseToAnyPublisher()
    }

    private var course: HCourse {
        .init(
            id: "123",
            institutionName: "Instructure",
            name: "Course Name",
            overviewDescription: "Course Description",
            progress: 0.5,
            enrollments: [],
            modules: []
        )
    }
}
#endif
