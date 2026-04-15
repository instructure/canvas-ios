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
import CombineSchedulers
import Foundation
import SwiftUI

@Observable
final class PrivacySettingsViewModel {

    private(set) var state: ScreenState = .loading

    private(set) var isAnalyticsEnabled: Bool = false
    var isAnalyticsEnabledBinding: Binding<Bool> {
        Binding(
            get: { self.isAnalyticsEnabled },
            set: { [weak self] value in
                self?.isAnalyticsEnabled = value
                self?.setAnalyticsConsent(to: value)
            }
        )
    }

    let snackBar = SnackBarViewModel()

    private let interactor: AnalyticsConsentInteractor
    private let mainScheduler: AnySchedulerOf<DispatchQueue>

    private var subscriptions = Set<AnyCancellable>()
    private var setConsentCancellable: AnyCancellable?

    init(
        interactor: AnalyticsConsentInteractor,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.mainScheduler = mainScheduler
    }

    func loadConsent() {
        state = .loading

        interactor.getConsentIfRequired(ignoreConsentCache: false)
            .replaceError(with: nil)
            .compactMap { $0 } // consent value should exist already
            .receive(on: mainScheduler)
            .sink { [weak self] value in
                self?.isAnalyticsEnabled = value
                self?.state = .data
            }
            .store(in: &subscriptions)
    }

    private func setAnalyticsConsent(to value: Bool) {
        setConsentCancellable = interactor.setConsent(value)
            .receive(on: mainScheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if completion.isFailure {
                        withAnimation {
                            self?.isAnalyticsEnabled.toggle()
                        }
                        self?.snackBar.showSnack(String(localized: "Failed to save setting", bundle: .core))
                    }
                },
                receiveValue: {
                    guard let handler = Analytics.shared.handler else {
                        Logger.shared.log("PrivacySettingsViewModel.setAnalyticsConsent(to: \(value ? "✅" : "❌")) sink: Analytics.shared.handler is nil ❌")
                        return
                    }

                    Logger.shared.log("PrivacySettingsViewModel.setAnalyticsConsent(to: \(value ? "✅" : "❌")) sink: Analytics.shared.handler exists ✅")
                    handler.handleConsentChange(to: value)
                }
            )
    }
}
