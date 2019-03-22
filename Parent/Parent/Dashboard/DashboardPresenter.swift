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

class DashboardPresenter {
    let env: AppEnvironment
    weak var view: DashboardViewController?

    lazy var permissions: Store<GetContextPermissions> = {
        let useCase = GetContextPermissions(context: ContextModel(.account, id: "self"), permissions: [.becomeUser])
        return env.subscribe(useCase, { [weak self] in
            self?.view?.updateMainView()
        })
    }()

    init(env: AppEnvironment = .shared, view: DashboardViewController) {
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        permissions.refresh(force: true)
    }
}
