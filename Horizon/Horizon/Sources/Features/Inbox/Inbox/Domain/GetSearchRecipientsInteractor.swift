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

struct Recipient {
    let id: String
    let name: String
}

protocol RecipientsSearchInteractor {
    var loading: CurrentValueSubject<Bool, Never> { get }
    var recipients: CurrentValueSubject<[Recipient], Never> { get }
    func search(with query: String, using context: Context)
}

class RecipientsSearchInteractorLive: RecipientsSearchInteractor {

    // MARK: - Outputs
    var loading: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    var recipients: CurrentValueSubject<[Recipient], Never> = CurrentValueSubject([])

    // MARK: - Private
    private var task: APITask?

    // MARK: - Dependencies
    private let api: API
    private let currentUserID: String?

    // MARK: - Init
    init(
        currentUserID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        api: API = AppEnvironment.shared.api
    ) {
        self.currentUserID = currentUserID
        self.api = api
    }

    // MARK: - Inputs
    func search(with query: String, using context: Context) {
        loading.send(true)
        task?.cancel()
        task = api.makeRequest(
            GetSearchRecipientsRequest(
                context: context,
                search: query,
                perPage: 10
            )
        ) { [weak self] result, _, _ in
            guard let self = self else {
                return
            }
            let apiSearchRecipients = result ?? []
            let recipients = apiSearchRecipients
                .filter { $0.id.value != self.currentUserID }
                .map {
                    Recipient(
                        id: $0.id.rawValue,
                        name: $0.name
                    )
                }
            self.recipients.send(recipients)
            self.loading.send(false)
        }
    }
}
