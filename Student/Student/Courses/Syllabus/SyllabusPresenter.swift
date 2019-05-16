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

import Foundation
import Core

protocol SyllabuseViewProtocol: class {
    func updateNavBar(courseCode: String?, backgroundColor: UIColor?)
    func loadHtml(_ html: String?)
    func showAssignmentsOnly()
}

class SyllabusPresenter {
    weak var view: SyllabuseViewProtocol?
    let env: AppEnvironment
    let courseID: String

    lazy var courses: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: courseID)
        return env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var colors: Store<GetCustomColors> = {
        let useCase = GetCustomColors()
        return env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    init(courseID: String, view: SyllabuseViewProtocol, env: AppEnvironment = .shared) {
        self.courseID = courseID
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        colors.refresh()
        courses.refresh()
        update()
    }

    func update() {
        view?.updateNavBar(courseCode: courses.first?.courseCode, backgroundColor: courses.first?.color)
        if let html = courses.first?.syllabusBody, courses.first != nil, !html.isEmpty {
            view?.loadHtml(html)
        } else if courses.first != nil {
            view?.showAssignmentsOnly()
        }
    }

    func show(_ url: URL, from viewController: UIViewController) {
        env.router.route(to: url, from: viewController)
    }
}
