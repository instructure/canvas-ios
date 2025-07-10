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

import Combine
import Core
import Foundation

protocol CustomGradebookColumnsInteractor {

}

final class CustomGradebookColumnsInteractorLive: CustomGradebookColumnsInteractor {

    private let courseId: String

    init(courseId: String) {
        self.courseId = courseId
    }

    private func getCustomColumns() -> AnyPublisher<[CDCustomGradebookColumn], Error> {
        let useCase = GetCustomGradebookColumns(courseId: courseId)
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .eraseToAnyPublisher()
    }

    /// Fetches the columns which are marked as `teacher_notes` (and aren't hidden).
    /// There should be only one "Notes" column at most, but we preapare for multiple.
    func getStudentNotesColumns() -> AnyPublisher<[CDCustomGradebookColumn], Error> {
        getCustomColumns()
            .map { columns in
                columns.filter { $0.isTeacherNotes && !$0.isHidden }
            }
            .eraseToAnyPublisher()
    }

    /// Fetches all entries for the given `columnId`. Each entry is assumed to belong to a different student.
    func getCustomColumnEntries(columnId: String) -> AnyPublisher<[CDCustomGradebookColumnEntry], Error> {
        let useCase = GetCustomGradebookColumnEntries(courseId: courseId, columnId: columnId)
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .eraseToAnyPublisher()
    }
}
