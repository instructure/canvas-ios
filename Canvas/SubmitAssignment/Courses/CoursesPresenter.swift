//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

    lazy var courses: Store<GetCourses> = env.subscribe(GetCourses(showFavorites: false)) { [weak self] in
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
