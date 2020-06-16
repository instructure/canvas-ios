//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

extension Tab: CourseNavigationViewModel {}

class CourseNavigationPresenter {
    weak var view: CourseNavigationViewProtocol?
    var context: Context
    let env: AppEnvironment

    lazy var color = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.update()
    }

    lazy var tabs = env.subscribe(GetContextTabs(context: context)) { [weak self] in
        self?.update()
    }

    init(courseID: String, view: CourseNavigationViewProtocol, env: AppEnvironment = .shared) {
        self.context = Context(.course, id: courseID)
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        courses.refresh()
        color.refresh()
        tabs.exhaust(while: { _ in true })
    }

    func update() {
        view?.update()
        view?.updateNavBar(title: courses.first?.name, backgroundColor: courses.first?.color)
    }
}
