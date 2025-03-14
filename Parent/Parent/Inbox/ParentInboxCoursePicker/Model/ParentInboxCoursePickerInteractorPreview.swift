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

import Core
import Foundation
import Combine

class ParentInboxCoursePickerInteractorPreview: ParentInboxCoursePickerInteractor {

    var state = CurrentValueSubject<StoreState, Never>(.data)
    var studentContextItems: CurrentValueSubject<[StudentContextItem], Never>

    func refresh() -> AnyPublisher<[Void], Never> {
        Future<[Void], Never> {_ in }.eraseToAnyPublisher()
    }

    func getCourseURL(courseId: String) -> String {
        return "https://instructure.com/courses/\(courseId)"
    }

    init(env: AppEnvironment) {
        let course1 = Course()
        let course2 = Course()
        course1.name = "Course 1"
        course2.name = "Course 2"

        studentContextItems = CurrentValueSubject<[StudentContextItem], Never>([
            StudentContextItem(studentId: "1", studentDisplayName: "Student 1", course: course1),
            StudentContextItem(studentId: "2", studentDisplayName: "Student 2", course: course2)
        ])
    }
}
