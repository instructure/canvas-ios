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

import XCTest
@testable import Core

final class SelectEventFrequencyViewModelTests: CoreTestCase {
    typealias DayOfWeek = RecurrenceRule.DayOfWeek

    private enum TestConstants {
        static let eventDate = Date.make(year: 2024, month: 3, day: 1, hour: 14, minute: 0)

        static let dailyFrequency: FrequencySelection = {
            let dailyRule = RecurrenceRule(
                recurrenceWith: .daily,
                interval: 1,
                end: .occurrenceCount(365)
            )
            return FrequencySelection(dailyRule, preset: .daily)
        }()

        static let selectedPreset: FrequencyPreset = {
            let rule = RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 2,
                daysOfTheWeek: [DayOfWeek(.sunday), DayOfWeek(.monday)],
                end: .occurrenceCount(10)
            )
            return .selected(title: "Weekly on Each Sunday, 10 times", rule: rule)
        }()

        static let customPreset: FrequencyPreset = {
            let rule = RecurrenceRule(recurrenceWith: .daily, interval: 1, end: .occurrenceCount(1))
            return .custom(rule)
        }()
    }

    private var model: SelectEventFrequencyViewModel!

    private var completionCallsCount: Int = 0
    private var completionValue: FrequencySelection?

    override func tearDown() {
        super.setUp()
        completionValue = nil
        model = nil
    }

    func testInitialization() {
        let frequency = TestConstants.dailyFrequency
        model = makeViewModel(
            selected: frequency.preset,
            originalPreset: .weeklyOnThatDay
        )

        XCTAssertEqual(model.eventDate, TestConstants.eventDate)
        XCTAssertEqual(model.selectedPreset, frequency.preset)
    }

    func testNoRepeatPresetSelected_NoPreSelection() {
        model = makeViewModel(selected: nil)

        triggerSelectingPreset(.noRepeat)
        XCTAssertEqual(completionCallsCount, 0)

        model.didTapBack.send()
        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, nil)
    }

    func testNoRepeatPresetSelected_WithPreSelection() {
        model = makeViewModel(selected: TestConstants.dailyFrequency.preset)

        XCTAssertEqual(model.selectedPreset, TestConstants.dailyFrequency.preset)

        triggerSelectingPreset(.noRepeat)
        model.didTapBack.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, nil)
    }

    func testPresetListGivenNoCustomPreSelection() {
        model = makeViewModel(selected: nil)
        XCTAssertEqual(
            model.presetViewModels.map({ $0.preset }),
            FrequencyPreset.predefinedPresets + [nil]
        )

        model = makeViewModel(selected: TestConstants.dailyFrequency.preset)
        XCTAssertEqual(
            model.presetViewModels.map({ $0.preset }),
            FrequencyPreset.predefinedPresets + [nil]
        )
    }

    func testPresetListGivenWithCustomPreSelection() {
        model = makeViewModel(originalPreset: TestConstants.selectedPreset)

        XCTAssertEqual(
            model.presetViewModels.map({ $0.preset }),
            FrequencyPreset.predefinedPresets + [TestConstants.selectedPreset, nil]
        )
    }

    func testCalculativePresetSelected() {
        model = makeViewModel()

        triggerSelectingPreset(TestConstants.dailyFrequency.preset)

        XCTAssertEqual(completionCallsCount, 0)

        model.didTapBack.send()
        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, TestConstants.dailyFrequency)
    }

    func testCustomPresetSelectedShouldShowCustomEditScreen() {
        let sourceVC = UIViewController()
        model = makeViewModel()

        triggerSelectingPreset(nil, vc: .init(sourceVC))

        guard let lastPresentation = router.viewControllerCalls.last else {
            return XCTFail()
        }

        XCTAssertTrue(lastPresentation.0 is CoreHostingController<EditCustomFrequencyScreen>)
        XCTAssertEqual(lastPresentation.1, sourceVC)
        XCTAssertEqual(lastPresentation.2, .push)
        XCTAssertEqual(completionCallsCount, 0)
    }

    func testCustomPresetSelectedShouldNotChangeSelection() {
        model = makeViewModel()
        triggerSelectingPreset(TestConstants.dailyFrequency.preset)

        triggerSelectingPreset(nil)

        XCTAssertEqual(model.isSelected(TestConstants.dailyFrequency.preset), true)

        model.didTapBack.send()
        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, TestConstants.dailyFrequency)
    }

    func testIsSelectedWhenThereIsNoPreselection() {
        model = makeViewModel()

        XCTAssertEqual(model.isSelected(.noRepeat), true)

        triggerSelectingPreset(TestConstants.dailyFrequency.preset)
        XCTAssertEqual(model.isSelected(TestConstants.dailyFrequency.preset), true)
    }

    func testIsSelectedWhenThereIsCustomPreselection() {
        model = makeViewModel(selected: TestConstants.customPreset)

        // Custom preset is not stored as is
        XCTAssertEqual(model.isSelected(TestConstants.customPreset), false)

        // Custom preset is represented as nil
        XCTAssertEqual(model.isSelected(nil), true)
    }

    // MARK: - Helpers

    private func makeViewModel(
        _ eventDate: Date = TestConstants.eventDate,
        selected: FrequencyPreset? = nil,
        originalPreset: FrequencyPreset = .noRepeat
    ) -> SelectEventFrequencyViewModel {
        return SelectEventFrequencyViewModel(
            eventDate: eventDate,
            initiallySelectedPreset: selected,
            eventsOriginalPreset: originalPreset,
            router: router,
            completion: { [weak self] freq in
                self?.completionCallsCount += 1
                self?.completionValue = freq
            }
        )
    }

    private func triggerSelectingPreset(_ preset: FrequencyPreset?, vc: WeakViewController? = nil) {
        let vc = vc ?? .init()
        model.didTapPreset.send((preset, vc))
    }
}

// MARK: - Helpers

private extension FrequencyPreset {
    var selectedTitle: String? {
        if case .selected(let title, _) = self { return title }
        return nil
    }
}
