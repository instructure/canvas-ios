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
final class ProfileViewModel {

    // MARK: - Output

    var name: String = "" {
        didSet {
            validateName()
            updateSaveDisabled()
        }
    }
    var nameDisabled: Bool {
        isLoading
    }
    var nameError: String = " "
    var displayName: String = "" {
        didSet {
            validateDisplayName()
            updateSaveDisabled()
        }
    }
    var displayNameDisabled: Bool {
        isLoading
    }
    var displayNameError: String = " "
    var email: String = ""
    var isSaveDisabled: Bool = true
    var isLoading: Bool = true

    // MARK: - Private

    private var displayNameOriginal: String = "" {
        didSet {
            displayName = displayNameOriginal
        }
    }

    private var nameOriginal: String = "" {
        didSet {
            name = nameOriginal
        }
    }
    private var subscriptions = Set<AnyCancellable>()
    private let updateUserProfileInteractor: UpdateUserProfileInteractor

    // MARK: - Init

    init(
        getUserInteractor: GetUserInteractor = GetUserInteractorLive(),
        updateUserProfileInteractor: UpdateUserProfileInteractor = UpdateUserProfileInteractorLive()
    ) {
        self.updateUserProfileInteractor = updateUserProfileInteractor

        getUserInteractor
            .getUser()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] user in
                    self?.nameOriginal = user.name
                    self?.displayNameOriginal = user.shortName ?? ""
                    self?.email = user.email ?? ""
                    self?.validate()
                    self?.isLoading = false
                }
            )
            .store(in: &subscriptions)
    }

    // MARK: - Input Actions

    func save() {
        isLoading = true
        updateUserProfileInteractor.set(name: name, shortName: displayName)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] userProfile in
                    self?.nameOriginal = userProfile?.name ?? ""
                    self?.displayNameOriginal = userProfile?.shortName ?? ""
                    self?.validate()
                }
            )
            .store(in: &subscriptions)
    }

    // MARK: - Private

    private var isDisplayNameChanged: Bool {
        displayName != displayNameOriginal
    }

    private var isDisplayNameValid: Bool {
        !displayName.isEmpty
    }

    private var isNameChanged: Bool {
        name != nameOriginal
    }

    private var isNameValid: Bool {
        !name.isEmpty
    }

    private func updateSaveDisabled() {
        isSaveDisabled = !isNameValid || !isDisplayNameValid || !(isNameChanged || isDisplayNameChanged)
    }

    private func validate() {
        validateName()
        validateDisplayName()
    }

    private func validateDisplayName() {
        displayNameError = isDisplayNameValid ? " " : "Display Name is required"
    }

    private func validateName() {
        nameError = isNameValid ? " " : String(localized: "Name is required", bundle: .horizon)
    }
}
