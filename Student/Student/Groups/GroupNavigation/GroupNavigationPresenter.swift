//
// Copyright (C) 2018-present Instructure, Inc.
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

protocol GroupNavigationViewProtocol: ErrorViewController {
    func updateNavBar(title: String, backgroundColor: UIColor)
    func update(color: UIColor)
}

extension Tab: GroupNavigationViewModel {}

class GroupNavigationPresenter {
    weak var view: GroupNavigationViewProtocol?
    var context: Context
    let env: AppEnvironment

    lazy var groups: Store<GetGroup> = {
        let useCase = GetGroup(groupID: context.id)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var tabs: Store<GetContextTabs> = {
        let useCase = GetContextTabs(context: context)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    init(groupID: String, view: GroupNavigationViewProtocol, env: AppEnvironment = .shared) {
        self.context = ContextModel(.group, id: groupID)
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        groups.refresh()
        tabs.refresh()
    }

    func update() {
        var color: UIColor = .black
        if let group = groups.first {
            color = group.color
            view?.updateNavBar(title: group.name, backgroundColor: color)
        }
        view?.update(color: color)
    }
}
