//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class K5ImportantDatesViewModel: ObservableObject {

    private let env = AppEnvironment.shared
    var context: Context { Context(.user, id: env.currentSession?.userID ?? "") }
    private lazy var dates = env.subscribe(GetCalendarEvents(context: context)) { [weak self] in
        self?.datesUpdated()
    }

    // MARK: Refresh
    private var refreshCompletion: (() -> Void)?
    private var forceRefresh = false

    init() {
        dates.refresh()
    }

    private func datesUpdated() {
        finishRefresh()
    }

    private func finishRefresh() {
        forceRefresh = false
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}

extension K5ImportantDatesViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        forceRefresh = true
        refreshCompletion = completion
        reloadData()
    }

    func reloadData() {
        dates.exhaust(force: true)
    }
}
