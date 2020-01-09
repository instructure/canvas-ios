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

    func showActAsUserScreen() {
        guard let view = view else {
            return
        }
        env.router.route(to: .actAsUser, from: view, options: [.modal, .embedInNav])
    }

    func showWrongAppScreen() {
        guard let view = view else {
            return
        }
        env.router.route(to: .wrongApp, from: view, options: [.modal, .embedInNav, .inPresentation])
    }
}
