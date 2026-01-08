//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Horizon
import Combine
import Core
import Foundation

final class RecipientsSearchInteractorMock: RecipientsSearchInteractor {

    // MARK: - Outputs
    var loading = CurrentValueSubject<Bool, Never>(false)
    var recipients = CurrentValueSubject<[Horizon.Recipient], Never>([])

    // MARK: - Tracking
    var searchCallCount = 0
    var lastSearchQuery: String?
    var lastSearchContext: Context?

    // MARK: - Inputs
    func search(with query: String, using context: Context) {
        searchCallCount += 1
        lastSearchQuery = query
        lastSearchContext = context
    }

    // MARK: - Helper Methods
    func simulateRecipients(_ recipientsList: [Horizon.Recipient]) {
        recipients.send(recipientsList)
    }

    func simulateLoading(_ isLoading: Bool) {
        loading.send(isLoading)
    }
}
