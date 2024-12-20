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

class LogEventListPresenter {
    let env: AppEnvironment
    weak var view: LogEventListViewProtocol?
    private(set) var currentFilter: LoggableType?

    lazy var events: Store<LocalUseCase<LogEvent>> = Store(env: env,
                                                           database: Logger.shared.database,
                                                           useCase: LocalUseCase(scope: LogEvent.scope(forType: nil))) { [weak self] in
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
        events = Store(env: env,
                       database: Logger.shared.database,
                       useCase: LocalUseCase(scope: LogEvent.scope(forType: type))) { [weak self] in
            self?.view?.reloadData()
        }
        events.refresh()
        view?.reloadData()
    }

    func clearAll() {
        env.logger.clearAll()
    }
}
