//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

protocol CoursesView: class {
    func update()
}

class CoursesPresenter {
    let env: AppEnvironment
    let selectedCourseID: String?
    let callback: (Course) -> Void
    weak var view: CoursesView?

    lazy var courses: Store<GetCourses> = env.subscribe(GetCourses()) { [weak self] in
        self?.view?.update()
    }

    init(environment: AppEnvironment, selectedCourseID: String?, callback: @escaping (Course) -> Void) {
        self.env = environment
        self.selectedCourseID = selectedCourseID
        self.callback = callback
    }

    func viewIsReady() {
        courses.refresh(force: true)
    }

    func selectCourse(at indexPath: IndexPath) {
        if let course = courses[indexPath] {
            callback(course)
        }
    }

    func getNextPage() {
        courses.getNextPage()
    }
}
