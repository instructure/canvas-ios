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
import Observation

@Observable
class ProfileAdvancedViewModel {

    var isLoading: Bool = false
    var isSaveDisabled: Bool = false
    var timeZone: String = "" {
        didSet {
            updateSaveDisabled()
        }
    }

    private let updateUserProfileInteractor: UpdateUserProfileInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(
        getUserInteractor: GetUserInteractor = GetUserInteractorLive(),
        updateUserProfileInteractor: UpdateUserProfileInteractor = UpdateUserProfileInteractorLive()
    ) {
        self.updateUserProfileInteractor = updateUserProfileInteractor

        self.isLoading = true
        getUserInteractor
            .getUser()
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] user in
                    self?.originalTimeZone = user.defaultTimeZone ?? ""
                }
            )
            .store(in: &subscriptions)
    }

    private var originalTimeZone = "" {
        didSet {
            timeZone = originalTimeZone
        }
    }

    func save() {
        isLoading = true
        updateUserProfileInteractor.set(timeZone: timeZone)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] userProfile in
                    self?.originalTimeZone = userProfile?.defaultTimeZone ?? ""
                    self?.updateSaveDisabled()
                }
            )
            .store(in: &subscriptions)
    }

    private func updateSaveDisabled() {
        isSaveDisabled = timeZone == originalTimeZone || timeZone.isEmpty
    }
}
