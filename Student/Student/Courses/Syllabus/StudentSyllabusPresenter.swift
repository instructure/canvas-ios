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
import Core

protocol StudentSyllabusViewProtocol: class {
    func updateNavBar(courseCode: String?, backgroundColor: UIColor?)
    func updateMenuHeight()
    func showAssignmentsOnly()
}

class StudentSyllabusPresenter {
    weak var view: StudentSyllabusViewProtocol?
    let env: AppEnvironment
    let courseID: String

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    init(courseID: String, view: StudentSyllabusViewProtocol, env: AppEnvironment = .shared) {
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
            view?.updateMenuHeight()
        } else if courses.first != nil && !courses.pending && !colors.pending {
            view?.showAssignmentsOnly()
        }
    }

    func show(_ url: URL, from viewController: UIViewController) {
        env.router.route(to: url, from: viewController)
    }
}
