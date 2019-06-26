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

class GradesWidgetPresenter {
    let env: AppEnvironment
    weak var view: GradesWidgetViewController?

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.view?.reload()
    }

    lazy var courses: Store<LocalUseCase<Course>> = env.subscribe(scope: .all(orderBy: #keyPath(Course.id))) { [weak self] in
        self?.view?.reload()
    }

    lazy var favorites = env.subscribe(GetCourses(showFavorites: true, perPage: 99)) { [weak self] in
        self?.view?.reload()
    }

    lazy var submissions = env.subscribe(GetRecentlyGradedSubmissions(userID: "self")) { [weak self] in
        self?.view?.reload()
    }

    init(env: AppEnvironment = .shared, view: GradesWidgetViewController) {
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        colors.refresh()
        favorites.refresh(force: true)
        submissions.refresh(force: true)
    }
}
