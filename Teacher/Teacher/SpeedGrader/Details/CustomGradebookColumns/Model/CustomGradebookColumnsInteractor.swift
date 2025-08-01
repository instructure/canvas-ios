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
    var courseId: String { get }

    /// Loads all Custom Columns data from API into CoreData, ignoring cache.
    /// It loads entries from all columns, for all students.
    /// This method is intended to be called when opening SpeedGrader to make sure it starts with fresh data.
    /// It's not intended to be called while paging between the students.
    func loadCustomColumnsData() -> AnyPublisher<Void, Error>

    /// Fetches all entries for the given `columnId`. Each entry is assumed to belong to a different student.
    func getCustomColumnEntries(columnId: String, ignoreCache: Bool) -> AnyPublisher<[CDCustomGradebookColumnEntry], Error>

    /// Fetches all Student Notes entries for the given `userId`.
    func getStudentNotesEntries(userId: String) -> AnyPublisher<[StudentNotesEntry], Error>
}

final class CustomGradebookColumnsInteractorLive: CustomGradebookColumnsInteractor {

    let courseId: String
    private let env: AppEnvironment

    init(courseId: String, env: AppEnvironment) {
        self.courseId = courseId
        self.env = env
    }

    // MARK: - Custom Columns

    /// Loads all Custom Columns data from API into CoreData, ignoring cache.
    /// It loads entries from all columns, for all students.
    /// This method is intended to be called when opening SpeedGrader to make sure it starts with fresh data.
    /// It's not intended to be called while paging between the students.
    func loadCustomColumnsData() -> AnyPublisher<Void, Error> {
        return getCustomColumns(ignoreCache: true)
            .flatMap { [self] columns -> AnyPublisher<Void, Error> in
                guard columns.isNotEmpty else { return Publishers.typedJust() }

                let publishers = columns.map { column in
                    getCustomColumnEntries(columnId: column.id, ignoreCache: true)
                        .mapToVoid()
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(publishers)
                    .collect()
                    .mapToVoid()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func getCustomColumns(ignoreCache: Bool = false) -> AnyPublisher<[CDCustomGradebookColumn], Error> {
        let useCase = GetCustomGradebookColumns(courseId: courseId)
        return ReactiveStore(useCase: useCase, environment: env)
            .getEntities(ignoreCache: ignoreCache)
            .eraseToAnyPublisher()
    }

    /// Fetches all entries for the given `columnId`. Each entry is assumed to belong to a different student.
    func getCustomColumnEntries(columnId: String, ignoreCache: Bool = false) -> AnyPublisher<[CDCustomGradebookColumnEntry], Error> {
        let useCase = GetCustomGradebookColumnEntries(courseId: courseId, columnId: columnId)
        return ReactiveStore(useCase: useCase, environment: env)
            .getEntities(ignoreCache: ignoreCache)
            .eraseToAnyPublisher()
    }

    /// Fetches the first entry for the given `columnId` with the given `userId`. Each entry in a column is assumed to belong to a different student.
    private func getCustomColumnEntry(columnId: String, with userId: String) -> AnyPublisher<CDCustomGradebookColumnEntry?, Error> {
        getCustomColumnEntries(columnId: columnId)
            .map { entries in
                entries.first { $0.userId == userId }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Student Notes

    /// Fetches the columns which are marked as `teacher_notes` (and aren't hidden).
    /// There should be only one "Notes" column at most, but we preapare for multiple.
    private func getStudentNotesColumns() -> AnyPublisher<[CDCustomGradebookColumn], Error> {
        getCustomColumns()
            .map { columns in
                columns.filter { $0.isTeacherNotes && !$0.isHidden }
            }
            .eraseToAnyPublisher()
    }

    /// Fetches all Student Notes entries for the given `userId`.
    func getStudentNotesEntries(userId: String) -> AnyPublisher<[StudentNotesEntry], Error> {
        getStudentNotesColumns()
            .flatMap { [self] columns -> AnyPublisher<[StudentNotesEntry], Error> in
                guard columns.isNotEmpty else { return Publishers.typedJust([]) }

                let publishers = columns.enumerated().map { (index, column) -> AnyPublisher<StudentNotesEntry, Error> in
                    getCustomColumnEntry(columnId: column.id, with: userId)
                        .compactMap { $0 }
                        .map {
                            StudentNotesEntry(
                                index: index, // not using `column.position` to make sure the values are unique
                                title: column.title,
                                content: $0.content
                            )
                        }
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(publishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
