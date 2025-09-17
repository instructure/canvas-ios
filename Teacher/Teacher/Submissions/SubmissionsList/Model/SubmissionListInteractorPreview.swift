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

class SubmissionListInteractorPreview: SubmissionListInteractor {

    let env: AppEnvironment
    let context = Context(.course, id: "1")
    let assignmentID = "1"

    init(env: AppEnvironment) {
        self.env = env
    }

    var submissions: AnyPublisher<[Submission], Never> {
        Just([]).eraseToAnyPublisher()
    }

    var assignment: AnyPublisher<Assignment?, Never> {
        let assignment: Assignment? = env
            .database
            .viewContext
            .first(scope: .all)
        return Just(assignment).eraseToAnyPublisher()
    }

    var course: AnyPublisher<Course?, Never> {
        Just(nil).eraseToAnyPublisher()
    }

    var courseSections: AnyPublisher<[Core.CourseSection], Never> {
        let sections: [CourseSection] = env
            .database
            .viewContext
            .fetch(scope: .where(\CourseSection.courseID, equals: "1"))
        return Just(sections).eraseToAnyPublisher()
    }

    var assigneeGroups: AnyPublisher<[AssigneeGroup], Never> {
        Just([]).eraseToAnyPublisher()
    }

    func refresh() -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    func applyPreference(_ pref: SubmissionListPreference) { }
}
