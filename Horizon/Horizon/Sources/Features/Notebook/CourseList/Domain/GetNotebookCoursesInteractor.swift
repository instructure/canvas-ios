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
import Core
import Foundation
import CombineExt

final class GetNotebookCoursesInteractor {
    // MARK: - Dependencies

    // MARK: - Private variables

    private var termPublisher: CurrentValueSubject<String, Error> = CurrentValueSubject("")

    private let userId: String

    // MARK: - Init

    init(userId: String = AppEnvironment.shared.currentSession?.userID ?? "") {
        self.userId = userId
    }

    // MARK: - Public

    func setTerm(_ value: String) {
        termPublisher.send(value)
    }

    func get() -> AnyPublisher<[NotebookCourse], any Error> {
        termPublisher
            .flatMap { searchTerm in
                ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: self.userId, searchTerm: searchTerm, orderByInstitution: true))
                    .getEntities()
                    .map { $0.compactMap { $0.notebookCourse } }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

extension CDCourseProgression {
    var notebookCourse: NotebookCourse? {
        NotebookCourse(
            id: courseID,
            course: course.name ?? "",
            institution: institutionName ?? "Unknown"
        )
    }
}
