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
    func loadCustomColumnsData() -> AnyPublisher<Void, Error>
    func getStudentNotesEntries(userId: String) -> AnyPublisher<[StudentNotesEntry], Error>
    func getIsStudentNotesEmpty(userId: String) -> AnyPublisher<Bool, Error>
}

final class CustomGradebookColumnsInteractorLive: CustomGradebookColumnsInteractor {

    private let courseId: String

    init(courseId: String) {
        self.courseId = courseId
    }

    // MARK: - Custom Columns

    /// Loads all Custom Columns data from API into CoreData, ignoring cache.
    /// It loads entries from all columns, for all students.
    func loadCustomColumnsData() -> AnyPublisher<Void, Error> {
        return getCustomColumns(ignoreCache: true)
            .flatMap { [weak self] columns -> AnyPublisher<Void, Error> in
                guard let self else { return Publishers.typedEmpty() }
                guard columns.isNotEmpty else { return Publishers.typedJust() }

                let publishers = columns.map { column in
                    self.getCustomColumnEntries(columnId: column.id, ignoreCache: true)
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

    func getCustomColumns(ignoreCache: Bool = false) -> AnyPublisher<[CDCustomGradebookColumn], Error> {
        let useCase = GetCustomGradebookColumns(courseId: courseId)
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .eraseToAnyPublisher()
    }

    /// Fetches all entries for the given `columnId`. Each entry is assumed to belong to a different student.
    func getCustomColumnEntries(columnId: String, ignoreCache: Bool = false) -> AnyPublisher<[CDCustomGradebookColumnEntry], Error> {
        let useCase = GetCustomGradebookColumnEntries(courseId: courseId, columnId: columnId)
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .eraseToAnyPublisher()
    }

    /// Fetches the first entry for the given `columnId` with the given `userId`. Each entry in a column is assumed to belong to a different student.
    func getCustomColumnEntry(columnId: String, with userId: String) -> AnyPublisher<CDCustomGradebookColumnEntry?, Error> {
        getCustomColumnEntries(columnId: columnId)
            .map { entries in
                entries.first { $0.userId == userId }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Student Notes

    /// Fetches the columns which are marked as `teacher_notes` (and aren't hidden).
    /// There should be only one "Notes" column at most, but we preapare for multiple.
    func getStudentNotesColumns() -> AnyPublisher<[CDCustomGradebookColumn], Error> {
        getCustomColumns()
            .map { columns in
                columns.filter { $0.isTeacherNotes && !$0.isHidden }
            }
            .eraseToAnyPublisher()
    }

    func getStudentNotesEntries(userId: String) -> AnyPublisher<[StudentNotesEntry], Error> {
        getStudentNotesColumns()
            .flatMap { [weak self] columns -> AnyPublisher<[StudentNotesEntry], Error> in
                guard let self else { return Publishers.typedEmpty() }
                guard columns.isNotEmpty else { return Publishers.typedJust([]) }

                let publishers = columns.enumerated().map { (index, column) -> AnyPublisher<StudentNotesEntry, Error> in
                    self.getCustomColumnEntry(columnId: column.id, with: userId)
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

    func getIsStudentNotesEmpty(userId: String) -> AnyPublisher<Bool, Error> {
        getStudentNotesEntries(userId: userId)
            .map(\.isEmpty)
            .eraseToAnyPublisher()
    }
}
