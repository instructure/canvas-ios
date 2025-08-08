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
        saveLoaderIsVisiable || !canUpdateName
    }
    var nameError: String = " "
    private(set) var errorMessage: String = ""
    private(set) var canUpdateName = true
    private(set) var isLoaderVisible = true
    var displayName: String = "" {
        didSet {
            validateDisplayName()
            updateSaveDisabled()
        }
    }
    var displayNameDisabled: Bool {
        saveLoaderIsVisiable || !canUpdateName
    }
    var displayNameError: String = " "
    var email: String = ""
    var isSaveDisabled: Bool = true
    var saveLoaderIsVisiable: Bool = false

    // MARK: - Inputs / Output

    var isAlertErrorPresented: Bool = false

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

        let userProfile = getUserInteractor.getUser()
        let userPermission = getUserInteractor.canUpdateName()

        Publishers.Zip(userProfile, userPermission)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.isAlertErrorPresented = true
                }
                self?.isLoaderVisible = false
            } receiveValue: { [weak self] (user, canUpdateName) in
                self?.canUpdateName = canUpdateName
                self?.nameOriginal = user.name
                self?.displayNameOriginal = user.shortName ?? ""
                self?.email = user.email ?? ""
                self?.validate()
            }
            .store(in: &subscriptions)
    }

    // MARK: - Input Actions

    func save() {
        saveLoaderIsVisiable = true
        updateUserProfileInteractor.set(name: name, shortName: displayName)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.saveLoaderIsVisiable = false
                },
                receiveValue: { [weak self] userProfile in
                    self?.nameOriginal = userProfile.name
                    self?.displayNameOriginal = userProfile.shortName ?? ""
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
