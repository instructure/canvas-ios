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

final class EditEventFrequencyViewModel: ObservableObject {

    // MARK: - Page Setup

    let pageTitle = String(localized: "Frequency", bundle: .core)
    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new/frequency")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    // MARK: - Data

    let eventDate: Date
    private let originalPreset: FrequencyPreset?

    var frequencyChoices: [FrequencyChoice] {
        var presets = FrequencyChoice.allCases(given: eventDate)
        if let preset = originalPreset, case .selected = preset {
            presets.append(FrequencyChoice(date: eventDate, preset: preset))
        }
        return presets
    }

    // MARK: - Actions & Utils

    let didTapBack = PassthroughSubject<Void, Never>()
    let didSelectCustomFrequency = PassthroughSubject<WeakViewController, Never>()

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Inputs / Outputs
    @Published private(set) var state: InstUI.ScreenState = .data
    @Published var selection: FrequencyPreset

    init(eventDate: Date,
         selectedFrequency: FrequencySelection?,
         originalPreset: FrequencyPreset?,
         router: Router,
         completion: @escaping (FrequencySelection?) -> Void) {

        self.router = router
        self.eventDate = eventDate
        self.originalPreset = originalPreset
        self.selection = selectedFrequency?.preset ?? .preset(given: selectedFrequency?.value, date: eventDate)

        didSelectCustomFrequency
            .sink { [weak self] weakVC in
                self?.showCustomFrequencyScreen(from: weakVC, completion: completion)
            }
            .store(in: &subscriptions)

        didTapBack
            .sink { [weak self] in
                guard let self,
                      let rule = self.selection.rule(given: eventDate)
                else { return completion(nil) }
                let frequency = FrequencySelection(rule, preset: selection)
                completion(frequency)
            }
            .store(in: &subscriptions)
    }

    private func showCustomFrequencyScreen(from source: WeakViewController,
                                           completion: @escaping (FrequencySelection?) -> Void) {

        let vc = CoreHostingController(
            EditCustomFrequencyScreen(
                viewModel: EditCustomFrequencyViewModel(
                    rule: selection.isCustom ? selection.rule(given: eventDate) : nil,
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
        vc.navigationItem.hidesBackButton = true
        router.show(vc, from: source, options: .push)
    }
}
