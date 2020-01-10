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

class PeopleListPresenter {
    let env: AppEnvironment
    let context: Context
    let viewController: PeopleListViewProtocol

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }

    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }

    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }

    lazy var users = env.subscribe(GetContextUsers(context: context)) { [weak self] in
        self?.viewController.update()
    }

    init(env: AppEnvironment, viewController: PeopleListViewProtocol, context: Context) {
        self.env = env
        self.context = context
        self.viewController = viewController
    }

    func viewIsReady() {
        colors.refresh()
        users.refresh()

        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
    }

    func updateNavBar() {
        guard let name = course.first?.name ?? group.first?.name, let color = course.first?.color ?? group.first?.color else {
            return
        }
        viewController.updateNavBar(subtitle: name, color: color)
    }

    func select(user: User, from: UIViewController) {
        env.router.route(to: "/\(context.pathComponent)/users/\(user.id)", from: from, options: [.detail, .embedInNav])
    }
}
