//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import SwiftUI
import Combine

final class SelectEventFrequencyViewModel: ObservableObject {

    // MARK: Output

    let pageTitle = String(localized: "Frequency", bundle: .core)
    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new/frequency")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    let presetViewModels: [FrequencyPresetViewModel]
    @Published private(set) var state: InstUI.ScreenState = .data
    @Published var selectedPreset: FrequencyPreset

    // MARK: - Input

    let didTapBack = PassthroughSubject<Void, Never>()
    let didSelectCustomFrequency = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private

    internal let eventDate: Date
    private let originalPreset: FrequencyPreset?

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        eventDate: Date,
        selectedFrequency: FrequencySelection?,
        originalPreset: FrequencyPreset?,
        router: Router,
        completion: @escaping (FrequencySelection?) -> Void
    ) {
        self.eventDate = eventDate
        self.selectedPreset = selectedFrequency?.preset ?? .noRepeat
        self.originalPreset = originalPreset
        self.router = router

        self.presetViewModels = {
            var presetViewModels = FrequencyPreset.predefinedPresets
                .map { FrequencyPresetViewModel(date: eventDate, preset: $0) }
            if let originalPreset, case .selected = originalPreset {
                presetViewModels.append(FrequencyPresetViewModel(date: eventDate, preset: originalPreset))
            }
            return presetViewModels
        }()

        didSelectCustomFrequency
            .sink { [weak self] weakVC in
                self?.showCustomFrequencyScreen(from: weakVC, completion: completion)
            }
            .store(in: &subscriptions)

        didTapBack
            .sink { [weak self] in
                guard let self,
                      let rule = self.selectedPreset.rule(given: eventDate)
                else { return completion(nil) }
                let frequency = FrequencySelection(rule, preset: selectedPreset)
                completion(frequency)
            }
            .store(in: &subscriptions)
    }

    private func showCustomFrequencyScreen(
        from source: WeakViewController,
        completion: @escaping (FrequencySelection?) -> Void
    ) {
        let vc = CoreHostingController(
            EditCustomFrequencyScreen(
                viewModel: EditCustomFrequencyViewModel(
                    rule: selectedPreset.isCustom ? selectedPreset.rule(given: eventDate) : nil,
                    proposedDate: eventDate,
                    router: router,
                    completion: { newRule in
                        completion(
                            FrequencySelection(newRule, preset: .custom(newRule))
                        )
                    }
                )
            )
        )
        router.show(vc, from: source, options: .push)
    }
}
