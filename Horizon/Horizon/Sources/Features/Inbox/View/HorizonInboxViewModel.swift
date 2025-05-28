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

    // MARK: - Private

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    init(
        addressBookInteractor: AddressbookInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.router = router

        addressBookInteractor.recipients.sink { [weak self] recipients in
            self?.personOptions = recipients.map { $0.name }
        }.store(in: &subscriptions)
    }

    func goBack(_ viewController: WeakViewController) {
        router.pop(from: viewController)
    }
}
