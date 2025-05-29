//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import Combine
import SwiftUI

@Observable
class HorizonInboxViewModel {

    // MARK: - Outputs
    var personOptions: [String] = []
    var filterByPersonSelections: [String] = []
    var filter: String = "" {
        didSet {
            onFilterSet()
        }
    }
    var searchLoading: Bool = false
    var isSearchFocused: Bool = false {
        didSet {
            onSearchFocused()
        }
    }

    // MARK: - Private

    private let api: API
    private var searchAPITask: APITask?
    private let router: Router
    private var searchDebounceTask: Task<Void, Never>?
    private var subscriptions = Set<AnyCancellable>()

    init(
        api: API = AppEnvironment.shared.api,
        router: Router = AppEnvironment.shared.router
    ) {
        self.api = api
        self.router = router
    }

    func goBack(_ viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    private func onFilterSet() {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            if Task.isCancelled {
                return
            }
            self?.makeRequest()
        }
    }

    private func onSearchFocused() {
        if isSearchFocused {
            makeRequest()
        }
    }

    private func makeRequest() {
        searchLoading = true
        searchAPITask?.cancel()
        searchAPITask = api.makeRequest(
            GetSearchRecipientsRequest(
                context: .user(AppEnvironment.shared.currentSession?.userID ?? ""),
                search: filter,
                perPage: 10
            )
        ) { [weak self] apiSearchRecipients, _, _ in
            guard let apiSearchRecipients = apiSearchRecipients else {
                return
            }
            self?.personOptions = apiSearchRecipients.map { $0.name }
            self?.searchLoading = false
        }
    }
}
