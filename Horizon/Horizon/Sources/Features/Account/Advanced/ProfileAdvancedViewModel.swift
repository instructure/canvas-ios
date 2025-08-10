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

    // MARK: - Outputs

    var isLoading: Bool = false
    var isSaveDisabled: Bool = false
    var isSelectDisabled: Bool {
        isLoading
    }
    var timeZone: String = "" {
        didSet {
            onTimeZoneSelected()
        }
    }
    var timeZones: [String] {
        TimeZones.labels
    }

    // MARK: - Private Properties

    private var timeZoneValue: String {
        TimeZones.value(for: timeZone) ?? ""
    }

    private var originalTimeZone = "" {
        didSet {
            timeZone = originalTimeZone
        }
    }

    // MARK: - Dependencies

    private let updateUserProfileInteractor: UpdateUserProfileInteractor
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

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

    // MARK: - Inputs

    func save() {
        if timeZoneValue.isEmpty {
            return
        }
        isLoading = true

        weak var weakSelf = self
        updateUserProfileInteractor.set(timeZone: timeZoneValue)
            .sink(
                receiveCompletion: { _ in
                    weakSelf?.isLoading = false
                },
                receiveValue: { userProfile in
                    weakSelf?.originalTimeZone = userProfile.defaultTimeZone ?? ""
                    weakSelf?.updateSaveDisabled()
                }
            )
            .store(in: &subscriptions)
    }

    // MARK: - Private Methods

    private func onTimeZoneSelected() {
        updateSaveDisabled()
    }

    private func updateSaveDisabled() {
        isSaveDisabled = timeZone == originalTimeZone || timeZone.isEmpty || timeZoneValue.isEmpty
    }

}
