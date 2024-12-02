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
    let courseNotesRepository: CourseNotesRepository

    let publisher = PassthroughSubject<[NotebookCourse], Never>()

    var cancellable: AnyCancellable?

    init(courseNotesRepository: CourseNotesRepository) {
        self.courseNotesRepository = courseNotesRepository
    }

    func search(for text: String) {
        cancellable = courseNotesRepository.get().sink(receiveCompletion: { _ in }, receiveValue: { [weak self] notes in
            guard let self = self else { return }

            let courses = notes
                .map { note in NotebookCourse(id: note.courseId, course: note.course, institution: note.institution) }
                .filter({ self.filterByText($0, text) })

            let coursesUnique = Array(Set(courses))
                .sorted(by: self.sortByInstitution)

            self.publisher.send(coursesUnique)
        })
    }

    func get() -> AnyPublisher<[NotebookCourse], Never> {
        publisher.eraseToAnyPublisher()
    }

    private func filterByText(_ course: NotebookCourse, _ text: String) -> Bool {
        text.isEmpty || course.course.lowercased().contains(text.lowercased()) || course.institution.lowercased().contains(text.lowercased())
    }

    private func sortByInstitution(_ courseA: NotebookCourse, _ courseB: NotebookCourse) -> Bool {
        courseA.institution == courseB.institution ? courseA.course < courseB.course : courseA.institution < courseB.institution
    }
}
