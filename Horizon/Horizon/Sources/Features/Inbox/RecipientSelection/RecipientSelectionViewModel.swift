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
import CombineExt
import CombineSchedulers
import Core
import Foundation
import HorizonUI
import Observation

@Observable
class RecipientSelectionViewModel {
    // MARK: - Outputs
    let isFocusedSubject = CurrentValueRelay<Bool>(false)
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
    var searchString: String = "" {
        didSet {
            searchStringSubject.send(searchString)
        }
    }

    // MARK: - Private
    private let contextSubject: CurrentValueSubject<Context, Never>
    private let searchStringSubject = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let currentUserID: String
    private let dispatchQueue: AnySchedulerOf<DispatchQueue>
    private let environment: AppEnvironment
    private let recipientsSearch: RecipientsSearchInteractor

    // MARK: - Init
    init(
        environment: AppEnvironment = .shared,
        currentUserID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        dispatchQueue: AnySchedulerOf<DispatchQueue> = .main,
        recipientsSearch: RecipientsSearchInteractor = RecipientsSearchInteractorLive()
    ) {
        self.environment = environment
        self.currentUserID = currentUserID
        self.contextSubject = .init(.user(currentUserID))
        self.dispatchQueue = dispatchQueue
        self.recipientsSearch = recipientsSearch

        listenForRecipients()
        listenForSearchStringUpdates()
    }

    // MARK: - Public Methods
    func clearSearch() {
        searchString = ""
        personOptions = []
        searchByPersonSelections = []
    }

    func setContext(_ context: Context) {
        contextSubject.send(context)
    }

    // MARK: - Private Methods

    private func listenForRecipients() {
        recipientsSearch.recipients
            .receive(on: dispatchQueue)
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

    private func listenForSearchStringUpdates() {
        Publishers.CombineLatest(
            searchStringSubject
                .debounce(for: .milliseconds(200), scheduler: dispatchQueue)
                .removeDuplicates(),
            contextSubject
        )
        .sink { [weak self] searchString, contextSubject in
            guard let self = self else {
                return
            }
            self.recipientsSearch.search(with: searchString, using: contextSubject)
        }
        .store(in: &subscriptions)
    }
}
