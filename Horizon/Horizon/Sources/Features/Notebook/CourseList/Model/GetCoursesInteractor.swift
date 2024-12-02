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
//        cancellable = courseNotesRepository.get().sink(receiveCompletion: { _ in }, receiveValue: { [weak self] notes in
//            let courses: [NotebookCourse] = []
            //notes
                //.map { note in NotebookCourse(institution: note.institution, name: note.course) }
                //.filter { text.isEmpty || $0.name.lowercased().contains(text.lowercased()) || $0.institution.lowercased().contains(text.lowercased()) }
                //.sorted { $0.institution == $1.institution ? $0.name < $1.name : $0.institution < $1.institution }
//            self?.publisher.send(courses)
//        })
    }

    func get() -> AnyPublisher<[NotebookCourse], Never> {
        publisher.eraseToAnyPublisher()
    }
}
