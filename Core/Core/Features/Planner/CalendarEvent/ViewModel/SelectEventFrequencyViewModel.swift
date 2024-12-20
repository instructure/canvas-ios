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
    @Published private(set) var selectedPreset: FrequencyPreset

    // MARK: - Input

    let didTapPreset = PassthroughSubject<(FrequencyPreset?, WeakViewController), Never>()
    let didTapBack = PassthroughSubject<Void, Never>()

    // MARK: - Private

    internal let eventDate: Date

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    /// - parameters:
    ///   - initiallySelectedPreset: The currently selected frequency when frequency selection began.
    ///   - eventsOriginalPreset: The event's original frequency when editing began.
    ///                           If this is a `.selected` preset, it will be displayed in it's own row.
    ///                           If this is a `.custom` preset, it will be ignored. This should not happen.
    init(
        eventDate: Date,
        initiallySelectedPreset: FrequencyPreset?,
        eventsOriginalPreset: FrequencyPreset,
        router: Router,
        completion: @escaping (FrequencySelection?) -> Void
    ) {
        self.eventDate = eventDate
        self.selectedPreset = initiallySelectedPreset ?? .noRepeat
        self.router = router

        self.presetViewModels = {
            var presets: [FrequencyPreset?] = FrequencyPreset.predefinedPresets

            if case .selected = eventsOriginalPreset {
                presets.append(eventsOriginalPreset)
            }

            // Always append a "Custom" row at the end
            presets.append(nil)

            return presets.map { FrequencyPresetViewModel(preset: $0, date: eventDate) }
        }()

        didTapPreset
            .sink { [weak self] (preset, weakVC) in
                guard let preset, !preset.isCustom else {
                    self?.showEditCustomFrequencyScreen(from: weakVC, completion: completion)
                    return // do not select Custom preset
                }

                self?.selectedPreset = preset
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

    func isSelected(_ preset: FrequencyPreset?) -> Bool {
        if selectedPreset.isCustom {
            // custom preset is represented as `nil`
            preset == nil
        } else {
            selectedPreset == preset
        }
    }

    private func showEditCustomFrequencyScreen(
        from source: WeakViewController,
        completion: @escaping (FrequencySelection?) -> Void
    ) {
        let vc = CoreHostingController(
            EditCustomFrequencyScreen(
                viewModel: EditCustomFrequencyViewModel(
                    rule: selectedPreset.rule(given: eventDate),
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
