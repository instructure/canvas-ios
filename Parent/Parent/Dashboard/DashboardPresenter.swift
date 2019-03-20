//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
