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

class GradesTodayWidgetPresenter {

    let env: AppEnvironment
    weak var view: GradesTodayWidgetViewController?

    lazy var courses: Store<GetCourses> = {
        let useCase = GetCourses(showFavorites: true, perPage: 99)
        return env.subscribe(useCase, { [weak self] in
            self?.view?.reload()
        })
    }()

    lazy var colors: Store<GetCustomColors> = {
        let useCase = GetCustomColors()
        return env.subscribe(useCase, { [weak self] in
            self?.view?.reload()
        })
    }()

    lazy var submissions: Store<GetRecentlyGradedSubmissions> = {
        let useCase = GetRecentlyGradedSubmissions(userID: "self")
        return env.subscribe(useCase, { [weak self] in
            self?.view?.reload()
        })
    }()

    init(env: AppEnvironment = .shared, view: GradesTodayWidgetViewController) {
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        courses.refresh(force: true)
        colors.refresh(force: false)
        submissions.refresh(force: true)
    }

}
