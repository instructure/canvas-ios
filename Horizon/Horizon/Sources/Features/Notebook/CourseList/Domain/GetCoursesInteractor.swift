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
import Foundation
import CombineExt

class GetCoursesInteractor {
    // MARK: - Dependencies

    private let courseNotesRepository: CourseNotesRepository

    // MARK: - Private variables

    private var termPublisher: CurrentValueSubject<String, Error> = CurrentValueSubject("")

    // MARK: - Init

    init(courseNotesRepository: CourseNotesRepository) {
        self.courseNotesRepository = courseNotesRepository
    }

    // MARK: - Public

    func setTerm(_ value: String) {
        termPublisher.send(value)
    }

    func get() -> AnyPublisher<[NotebookCourse], Error> {
        courseNotesRepository
            .get()
            .map({ notes in notes.map({ NotebookCourse(from: $0) }) })
            .map(filterToUnique)
            .combineLatest(termPublisher.map({ $0.lowercased() }))
            .map(filterByText)
            .map(sortByInstitution)
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func filterByText(courses: [NotebookCourse], term: String) -> [NotebookCourse] {
        return courses.filter({ course in
            term.isEmpty ||
            course.course.lowercased().contains(term.lowercased()) ||
            course.institution.lowercased().contains(term.lowercased())
        })
    }

    private func filterToUnique(_ courses: [NotebookCourse]) -> [NotebookCourse] {
        Array(Set(courses))
    }

    private func sortByInstitution(_ courses: [NotebookCourse]) -> [NotebookCourse] {
        courses.sorted(by: { lhs, rhs in
            lhs.institution == rhs.institution ?
            lhs.course < rhs.course :
            lhs.institution < rhs.institution
        })
    }
}
