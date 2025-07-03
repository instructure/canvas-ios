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

import Combine
import Core
import HorizonUI
import SwiftUI

@Observable
class PeopleSelectionViewModel {
    // MARK: - Outputs
    var isFocused: Bool = false {
        didSet {
            onFocused()
        }
    }
    var personOptions: [HorizonUI.MultiSelect.Option] = []
    var recipientIDs: [String] {
        searchByPersonSelections.map { $0.id }
    }
    var searchByPersonSelections: [HorizonUI.MultiSelect.Option] {
        get {
            personFilterSubject.value
        }
        set {
            personFilterSubject.send(newValue)
        }
    }
    let personFilterSubject = CurrentValueSubject<[HorizonUI.MultiSelect.Option], Never>([])
    var searchLoading: Bool = false

    // MARK: - Private
    private var searchAPITask: APITask?
    private var searchDebounceTask: Task<Void, Never>?
    var searchString: String = "" {
        didSet {
            onSearchStringSet()
        }
    }

    // MARK: - Dependencies
    private let api: API
    private let currentUserID: String?

    // MARK: - Init
    init(
        api: API = AppEnvironment.shared.api,
        currentUserID: String? = AppEnvironment.shared.currentSession?.userID
    ) {
        self.api = api
        self.currentUserID = currentUserID
    }

    // MARK: - Public Methods
    func clearSearch() {
        searchString = ""
        personOptions = []
        searchByPersonSelections = []
    }

    // MARK: - Private Methods
    private func makeRequest() {
        searchLoading = true
        searchAPITask?.cancel()
        searchAPITask = api.makeRequest(
            GetSearchRecipientsRequest(
                context: .user(AppEnvironment.shared.currentSession?.userID ?? ""),
                search: searchString,
                perPage: 10
            )
        ) { [weak self] apiSearchRecipients, _, _ in
            guard let apiSearchRecipients = apiSearchRecipients else {
                return
            }
            self?.personOptions = apiSearchRecipients
                .filter { $0.id.value != self?.currentUserID }
                .map {
                    HorizonUI.MultiSelect.Option(
                        id: $0.id.rawValue,
                        label: $0.name
                    )
                }
            self?.searchLoading = false
        }
    }

    private func onFocused() {
        if isFocused {
            makeRequest()
        }
    }

    private func onSearchStringSet() {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            if Task.isCancelled {
                return
            }
            self?.makeRequest()
        }
    }
}
