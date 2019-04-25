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

class LogEventListPresenter {
    let env: AppEnvironment
    weak var view: LogEventListViewProtocol?
    private(set) var currentFilter: LoggableType?

    lazy var events: Store<LocalUseCase<LogEvent>> = env.subscribe(scope: LogEvent.scope(forType: nil)) { [weak self] in
        self?.view?.reloadData()
    }

    init(env: AppEnvironment = .shared, view: LogEventListViewProtocol) {
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        events.refresh()
        view?.reloadData()
    }

    func applyFilter(_ type: LoggableType?) {
        currentFilter = type
        events = env.subscribe(scope: LogEvent.scope(forType: type)) { [weak self] in
            self?.view?.reloadData()
        }
        events.refresh()
        view?.reloadData()
    }

    func clearAll() {
        env.logger.clearAll()
    }
}
