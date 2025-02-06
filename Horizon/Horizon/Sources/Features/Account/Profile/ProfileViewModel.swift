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

import Observation

@Observable
final class ProfileViewModel {

    // MARK: - Output

    var name: String = "Reed Abbott" {
        didSet {
            validateName()
        }
    }
    var nameError: String = " "
    var displayName: String = "Reed" {
        didSet {
            validateDisplayName()
        }
    }
    var displayNameError: String = " "
    var email: String = "reabbotted@gmail.com"
    var isSaveDisabled: Bool {
        !isNameValid || !isDisplayNameValid
    }

    // MARK: - Init

    init() {
    }

    // MARK: - Input Actions

    func save() {
    }

    // MARK: - Private

    private var isDisplayNameValid: Bool {
        !displayName.isEmpty
    }

    private var isNameValid: Bool {
        !name.isEmpty
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
