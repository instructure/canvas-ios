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
public final class PrivacySettingsViewModel {

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

    public init(
        interactor: AnalyticsConsentInteractor,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.mainScheduler = mainScheduler
    }

    func loadConsent() {
        state = .loading

        interactor.getConsentIfRequired()
            .replaceError(with: nil)
            .receive(on: mainScheduler)
            .sink { [weak self] value in
                // consent value should exist already
                guard let value else {
                    self?.state = .error
                    return
                }

                self?.isAnalyticsEnabled = value
                self?.state = .data
            }
            .store(in: &subscriptions)
    }

    private func setAnalyticsConsent(to value: Bool) {
        do {
            try interactor.setConsent(value)
            Analytics.shared.handler?.handleConsentChange(to: value)
        } catch {
            withAnimation {
                isAnalyticsEnabled.toggle()
            }
            snackBar.showSnack(String(localized: "Failed to save setting", bundle: .core))
        }
    }
}
