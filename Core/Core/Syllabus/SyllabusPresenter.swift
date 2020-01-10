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

import Foundation

protocol SyllabusViewProtocol: class {
    func loadHtml(_ html: String?)
}

class SyllabusPresenter {
    weak var view: SyllabusViewProtocol?
    let courseID: String
    let env: AppEnvironment

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    init(view: SyllabusViewProtocol, courseID: String, env: AppEnvironment = .shared) {
        self.view = view
        self.courseID = courseID
        self.env = env
    }

    func viewIsReady() {
        courses.refresh()
    }

    func update() {
        if !courses.pending,
            let course = courses.first,
            let html = course.syllabusBody, !html.isEmpty {
            view?.loadHtml(html)
        }
    }

    func show(_ url: URL, from viewController: UIViewController) {
        env.router.route(to: url, from: viewController)
    }
}
