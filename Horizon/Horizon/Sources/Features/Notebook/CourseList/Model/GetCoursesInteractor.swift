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

    let publisher = PassthroughSubject<[NotebookCourse], Never>()

    let courses = [
        NotebookCourse(institution: "Instructure", name: "Canvas"),
        NotebookCourse(institution: "Instructure", name: "Bridge"),
        NotebookCourse(institution: "Instructure", name: "Arc"),
        NotebookCourse(institution: "Instructure", name: "Portfolium"),
        NotebookCourse(institution: "Yale", name: "Intro to Psychology"),
        NotebookCourse(institution: "Yale", name: "Intro to Philosophy"),
        NotebookCourse(institution: "Yale", name: "Intro to Biology")
    ]

    func search(for text: String) {
        if(text.isEmpty) {
            publisher.send(courses)
            return
        }
        publisher.send(
            courses.filter { $0.name.lowercased().contains(text.lowercased()) || $0.institution.lowercased().contains(text.lowercased()) }
        )
    }

    func get() -> AnyPublisher<[NotebookCourse], Never> {
        publisher.eraseToAnyPublisher()
    }
}
