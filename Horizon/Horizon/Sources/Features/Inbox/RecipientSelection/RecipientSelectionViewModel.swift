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
import CombineSchedulers
import Core
import Foundation
import HorizonUI
import Observation

@Observable
class RecipientSelectionViewModel {
    // MARK: - Outputs
    var context: Context {
        didSet {
            makeRequest()
        }
    }
    var isFocused: Bool = false {
        didSet {
            onFocused(oldValue: oldValue)
        }
    }
    let isFocusedSubject = CurrentValueSubject<Bool, Never>(false)
    var dismissKeyboard: (() -> Void)?
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
    private var searchDebounceTask: Task<Void, Never>?
    var searchString: String = "" {
        didSet {
            searchStringSubject.send(searchString)
        }
    }
    private let searchStringSubject = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let api: API
    private let currentUserID: String
    private let dispatchQueue: AnySchedulerOf<DispatchQueue>
    private let environment: AppEnvironment
    private let recipientsSearch: RecipientsSearchInteractor

    // MARK: - Init
    init(
        environment: AppEnvironment = .shared,
        api: API = AppEnvironment.shared.api,
        currentUserID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        dispatchQueue: AnySchedulerOf<DispatchQueue> = .main,
        recipientsSearch: RecipientsSearchInteractor = RecipientsSearchInteractorLive()
    ) {
        self.environment = environment
        self.api = api
        self.currentUserID = currentUserID
        self.context = .user(currentUserID)
        self.dispatchQueue = dispatchQueue
        self.recipientsSearch = recipientsSearch

        recipientsSearch.recipients
            .sink { [weak self] recipients in
                self?.personOptions = recipients.map {
                    HorizonUI.MultiSelect.Option(
                        id: $0.id,
                        label: $0.name
                    )
                }
            }
            .store(in: &subscriptions)
    }

    // MARK: - Public Methods
    func clearSearch() {
        searchString = ""
        personOptions = []
        searchByPersonSelections = []
    }

    // MARK: - Private Methods
    private func makeRequest() {
        recipientsSearch.search(with: searchString, using: context)
    }

    private func onFocused(oldValue: Bool = false) {
        if oldValue && !isFocused {
            dismissKeyboard?()
        }
        if isFocused {
            makeRequest()
        }
        isFocusedSubject.send(isFocused)
    }

    private func onSearchStringSet() {
        searchStringSubject
            .debounce(for: .milliseconds(500), scheduler: dispatchQueue)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.makeRequest()
            }
            .store(in: &subscriptions)
    }
}
