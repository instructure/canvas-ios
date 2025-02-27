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

public class InboxSettingsViewModel: ObservableObject {
    @Published public var useSignature: Bool = false
    @Published public var signature: String = ""
    @Published public var enableSaveButton: Bool = false

    private let inboxSettingsInteractor: InboxSettingsInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: InboxSettingsInteractor) {
        self.inboxSettingsInteractor = interactor
    }

    private func setupOutputBindings() {
        inboxSettingsInteractor
            .signature
            .sink { [weak self] (useSignature, signature) in
                self?.useSignature = useSignature ?? false
                self?.signature = signature ?? ""
            }
            .store(in: &subscriptions)
    }
}
