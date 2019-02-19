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

class LogEventListPresenter: FetchedResultsControllerDelegate {
    let env: AppEnvironment
    weak var view: LogEventListViewProtocol?
    var events: FetchedResultsController<LogEvent>
    private(set) var currentFilter: LogEvent.ScopeKeys?

    init(env: AppEnvironment = .shared, view: LogEventListViewProtocol) {
        self.env = env
        self.view = view
        events = env.subscribe(LogEvent.self, .all)
        events.delegate = self
    }

    var numberOfEvents: Int {
        return events.sections?[0].numberOfObjects ?? 0
    }

    func viewIsReady() {
        events.performFetch()
        view?.reloadData()
    }

    func applyFilter(_ scope: LogEvent.ScopeKeys) {
        currentFilter = scope
        events = env.subscribe(LogEvent.self, scope)
        events.delegate = self
        events.performFetch()
        view?.reloadData()
    }

    func logEvent(for indexPath: IndexPath) -> LogEvent? {
        return events.object(at: indexPath)
    }

    func clearAll() {
        env.logger.clearAll()
    }

    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        view?.reloadData()
    }
}
