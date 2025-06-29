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

import Foundation
import Combine
import CombineExt
import UIKit

public class InboxSettingsViewModel: ObservableObject {
    @Published public var useSignature: Bool = false
    @Published public var signature: String = ""
    @Published public var enableSaveButton: Bool = false
    @Published public var state: InstUI.ScreenState = .loading
    @Published public var showFailedToSaveDialog: Bool = false
    @Published public var showFailedToLoadDialog: Bool = false

    public let didTapSave = PassthroughRelay<WeakViewController>()
    public let didTapRefresh = PassthroughRelay<WeakViewController>()
    public let didTapBack = PassthroughRelay<WeakViewController>()

    private let inboxSettingsInteractor: InboxSettingsInteractor
    private var subscriptions = Set<AnyCancellable>()
    private var inboxSettings: CDInboxSettings?
    private let env: AppEnvironment

    init(interactor: InboxSettingsInteractor, env: AppEnvironment) {
        self.inboxSettingsInteractor = interactor
        self.env = env

        setupOutputBindings()
        setupInputBindings()
    }

    private func setupOutputBindings() {
        inboxSettingsInteractor
            .signature
            .sink { [weak self] (useSignature, signature) in
                self?.useSignature = useSignature
                self?.signature = signature ?? ""
            }
            .store(in: &subscriptions)

        inboxSettingsInteractor
            .settings
            .sink { [weak self] settings in
                self?.inboxSettings = settings
            }
            .store(in: &subscriptions)

        inboxSettingsInteractor
            .state
            .sink { [weak self] s in
                switch s {
                case .data, .empty:
                    self?.state = .data
                case .error:
                    self?.state = .error
                    self?.showFailedToLoadDialog = true
                case .loading:
                    self?.state = .loading
                }
            }
            .store(in: &subscriptions)
    }

    private func setupInputBindings() {
        didTapSave
            .flatMap { [weak self] controller in
                guard let self, let newSttings = self.inboxSettings else {
                    return Just(controller).ignoreOutput(setOutputType: WeakViewController?.self).eraseToAnyPublisher()
                }

                self.state = .loading

                newSttings.useSignature = useSignature
                newSttings.signature = signature
                return self.inboxSettingsInteractor
                    .updateInboxSettings(inboxSettings: newSttings)
                    .map { _ in controller }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] controller in
                if let controller {
                    _ = UIAccessibility.announcePersistently(String(localized: "Changes successfully saved", bundle: .core))
                    self?.env.router.pop(from: controller)
                } else {
                    self?.showFailedToSaveDialog = true
                }
            }
            .store(in: &subscriptions)

        didTapRefresh
            .sink { [weak self] _ in
                self?.inboxSettingsInteractor.refresh()
            }
            .store(in: &subscriptions)

        didTapBack
            .sink { [weak self] controller in
                self?.env.router.pop(from: controller)
            }
            .store(in: &subscriptions)

        Publishers.Merge(
            _useSignature
                .projectedValue
                .mapToVoid(),
            _signature
                .projectedValue
                .mapToVoid()
        )
        .dropFirst(4)
        .sink { [weak self] _ in
            self?.enableSaveButton = true
        }
        .store(in: &subscriptions)
    }
}
