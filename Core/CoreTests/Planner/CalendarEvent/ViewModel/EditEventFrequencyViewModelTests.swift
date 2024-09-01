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

final class EditEventFrequencyViewModelTests: CoreTestCase {

    private enum TestConstants {
        static let eventDate = Date.make(year: 2024, month: 3, day: 1, hour: 14, minute: 0)

        static let dailyFrequency: FrequencySelection = {
            let dailyRule = RecurrenceRule(
                recurrenceWith: .daily,
                interval: 1,
                end: RecurrenceEnd(occurrenceCount: 365))
            return FrequencySelection(dailyRule, preset: .daily)
        }()

        static let selectedFrequency: FrequencySelection = {
            let rule = RecurrenceRule(recurrenceWith: .weekly,
                                      interval: 2,
                                      daysOfTheWeek: [DayOfWeek(.sunday), DayOfWeek(.monday)],
                                      end: RecurrenceEnd(occurrenceCount: 10))
            let seriesNaturalLanguage = "Weekly on Each Sunday, 10 times"
            return FrequencySelection(rule,
                                      title: seriesNaturalLanguage,
                                      preset: .selected(title: seriesNaturalLanguage, rule: rule))

        }()
    }

    private var completionValue: FrequencySelection?

    override func setUp() {
        super.setUp()
        completionValue = nil
    }

    func testInitialValues() {
        let frequency = TestConstants.dailyFrequency
        let model = makeViewModel(
            TestConstants.eventDate,
            selected: frequency,
            originalPreset: .weeklyOnThatDay)

        XCTAssertEqual(model.eventDate, TestConstants.eventDate)
        XCTAssertEqual(model.selectedRule, frequency.value)
        XCTAssertEqual(model.originalPreset, .weeklyOnThatDay)
        XCTAssertEqual(model.selection, frequency.preset)
    }

    func testNoRepeatPresetSelected_NoPreSelection() {
        let model = makeViewModel(TestConstants.eventDate)

        model.selection = .noRepeat
        XCTAssertNil(completionValue)

        model.didTapBack.send()
        XCTAssertNil(completionValue)
    }

    func testNoRepeatPresetSelected_WithPreSelection() {
        let model = makeViewModel(
            TestConstants.eventDate,
            selected: TestConstants.dailyFrequency
        )

        XCTAssertEqual(model.selection, TestConstants.dailyFrequency.preset)

        model.selection = .noRepeat
        model.didTapBack.send()

        XCTAssertNil(completionValue)
    }

    func testPresetChoicesGivenNoCustomPreSelection() {
        var model = makeViewModel(TestConstants.eventDate)
        XCTAssertEqual(model.frequencyChoices.map({ $0.preset }), FrequencyPreset.choicesPresets)

        model = makeViewModel(TestConstants.eventDate, selected: TestConstants.dailyFrequency)
        XCTAssertEqual(model.frequencyChoices.map({ $0.preset }), FrequencyPreset.choicesPresets)
    }

    func testPresetChoicesGivenWithCustomPreSelection() {
        let model = makeViewModel(
            TestConstants.eventDate,
            selected: TestConstants.selectedFrequency,
            originalPreset: TestConstants.selectedFrequency.preset
        )

        let modifiedChoicePresets = model.frequencyChoices.map({ $0.preset })
        let expectedPresetsList = FrequencyPreset.choicesPresets + [
            TestConstants.selectedFrequency.preset
        ]

        XCTAssertEqual(modifiedChoicePresets, expectedPresetsList)
        XCTAssertEqual(model.frequencyChoices.last?.title, TestConstants.selectedFrequency.preset.selectedTitle)
    }

    func testCalculativePresetSelected() {
        let model = makeViewModel(TestConstants.eventDate)
        model.selection = TestConstants.dailyFrequency.preset

        XCTAssertNil(completionValue)

        model.didTapBack.send()
        XCTAssertEqual(completionValue, TestConstants.dailyFrequency)
    }

    func testCustomPresetSelected() {
        let sourceVC = UIViewController()
        let model = makeViewModel(TestConstants.eventDate)

        model.didSelectCustomFrequency.send(WeakViewController(sourceVC))

        guard let lastPresentation = router.viewControllerCalls.last else {
            return XCTFail()
        }

        XCTAssertTrue(lastPresentation.0 is CoreHostingController<EditCustomFrequencyScreen>)
        XCTAssertEqual(lastPresentation.1, sourceVC)
        XCTAssertEqual(lastPresentation.2, .push)
    }

    // MARK: - Helpers

    private func makeViewModel(_ eventDate: Date,
                               selected: FrequencySelection? = nil,
                               originalPreset: FrequencyPreset? = nil) -> EditEventFrequencyViewModel {

        return EditEventFrequencyViewModel(
            eventDate: eventDate,
            selectedFrequency: selected,
            originalPreset: originalPreset,
            router: router,
            completion: { [weak self] freq in
                self?.completionValue = freq
            }
        )
    }
}

// MARK: - Helpers

extension FrequencyPreset {
    fileprivate var selectedTitle: String? {
        if case .selected(let title, _) = self { return title }
        return nil
    }
}
