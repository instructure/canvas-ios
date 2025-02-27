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

public class InboxSettingsViewModel: ObservableObject {
    @Published public var useSignature: Bool = false
    @Published public var signature: String = ""
    @Published public var enableSaveButton: Bool = false

    public let didTapSave = PassthroughRelay<WeakViewController>()

    private let inboxSettingsInteractor: InboxSettingsInteractor
    private var subscriptions = Set<AnyCancellable>()
    private var inboxSettings: CDInboxSettings?
    private let router: Router

    init(interactor: InboxSettingsInteractor, router: Router) {
        self.inboxSettingsInteractor = interactor
        self.router = router

        setupOutputBindings()
        setupInputBindings()
    }

    private func setupOutputBindings() {
        inboxSettingsInteractor
            .signature
            .sink { [weak self] (useSignature, signature) in
                self?.useSignature = useSignature ?? false
                self?.signature = signature ?? ""
            }
            .store(in: &subscriptions)

        inboxSettingsInteractor
            .settings
            .sink { [weak self] settings in
                self?.inboxSettings = settings
            }
            .store(in: &subscriptions)
    }

    private func setupInputBindings() {
        didTapSave
            .flatMap { [weak self, inboxSettings, useSignature, signature] controller in
                guard let inboxSettings, let self else { return Just(controller).setFailureType(to: Error.self).eraseToAnyPublisher() }
                inboxSettings.useSignature = useSignature
                inboxSettings.signature = signature
                return self.inboxSettingsInteractor
                    .updateInboxSettings(inboxSettings: inboxSettings)
                    .map { _ in controller }
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { result in
                print("Failed to update")
            }, receiveValue: { [router] controller in
                router.pop(from: controller)
            })
            .store(in: &subscriptions)

        _useSignature
            .projectedValue
            .dropFirst()
            .dropFirst()
            .sink { [weak self] _ in
                self?.enableSaveButton = true
            }
            .store(in: &subscriptions)

        _signature
            .projectedValue
            .dropFirst()
            .dropFirst()
            .sink { [weak self] _ in
                self?.enableSaveButton = true
            }
            .store(in: &subscriptions)
    }
}
