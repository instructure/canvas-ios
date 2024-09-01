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

final class EditCustomFrequencyViewModelTests: CoreTestCase {

    private var completionValue: RecurrenceRule?

    override func setUp() {
        super.setUp()
        Clock.mockNow(TestConstants.dateNow)
        completionValue = nil
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func test_initialization() {

        for useCase in TestConstants.readingUseCases {
            let model = makeViewModel(TestConstants.eventDate, selected: useCase.rule)
            let expected = useCase.expected

            XCTAssertEqual(model.proposedDate, TestConstants.eventDate)
            XCTAssertEqual(model.frequency, expected.frequency)
            XCTAssertEqual(model.interval, expected.interval)

            XCTAssertNotNil(model.end)
            XCTAssertEqual(model.endMode, expected.endMode)
            XCTAssertEqual(model.endDate, expected.endDate)
            XCTAssertEqual(model.occurrenceCount, expected.occurrenceCount)

            XCTAssertEqual(model.daysOfTheWeek, expected.daysOfTheWeek)
            XCTAssertEqual(model.dayOfMonth, expected.dayOfMonth)
            XCTAssertEqual(model.dayOfYear, expected.dayOfYear)
        }
    }

    func test_save_button_enablement() {
        let noEndRule = RecurrenceRule(recurrenceWith: .daily, interval: 1)
        let model = makeViewModel(TestConstants.eventDate, selected: noEndRule)

        XCTAssertNil(model.end)
        XCTAssertEqual(model.isSaveButtonEnabled, false)

        model.endMode = .afterOccurrences
        model.occurrenceCount = 4

        XCTAssertNotNil(model.end)
        XCTAssertEqual(model.isSaveButtonEnabled, true)

        model.endMode = .onDate
        model.endDate = nil

        XCTAssertNil(model.end)
        XCTAssertEqual(model.isSaveButtonEnabled, false)

        model.endMode = .afterOccurrences
        model.occurrenceCount = 0

        XCTAssertNil(model.end)
        XCTAssertEqual(model.isSaveButtonEnabled, false)
    }

    func test_frequency_change() {
        let model = makeViewModel(TestConstants.eventDate)

        model.frequency = .daily
        XCTAssertNil(model.dayOfYear)

        model.frequency = .yearly
        XCTAssertNotNil(model.dayOfYear)
        XCTAssertEqual(model.dayOfYear?.day, TestConstants.eventDate.day)
        XCTAssertEqual(model.dayOfYear?.month, TestConstants.eventDate.month)
    }

    func test_rule_translation() {

        for useCase in TestConstants.translatingUseCases {

            let values = useCase.expected
            let model = makeViewModel(TestConstants.eventDate)

            model.frequency = values.frequency
            model.interval = values.interval

            model.endMode = values.endMode
            model.endDate = values.endDate
            model.occurrenceCount = values.occurrenceCount

            model.daysOfTheWeek = values.daysOfTheWeek
            model.dayOfMonth = values.dayOfMonth
            model.dayOfYear = values.dayOfYear

            XCTAssertEqual(model.translatedRule, useCase.rule)
        }
    }

    func test_done_tapped() {
        let values = TestConstants.monthlyUseCase.expected
        let model = makeViewModel(TestConstants.eventDate)

        model.frequency = values.frequency
        model.interval = values.interval

        model.endMode = values.endMode
        model.endDate = values.endDate
        model.occurrenceCount = values.occurrenceCount

        model.daysOfTheWeek = values.daysOfTheWeek
        model.dayOfMonth = values.dayOfMonth
        model.dayOfYear = values.dayOfYear

        let sourceVC = UIViewController()
        model.didTapDone.send(WeakViewController(sourceVC))

        XCTAssertEqual(completionValue, model.translatedRule)
        XCTAssertEqual(router.popped, sourceVC)
    }

    // MARK: - Helpers

    private func makeViewModel(_ eventDate: Date, selected: RecurrenceRule? = nil) -> EditCustomFrequencyViewModel {
        return EditCustomFrequencyViewModel(
            rule: selected,
            proposedDate: eventDate,
            router: router,
            completion: { [weak self] newRule in
                self?.completionValue = newRule
            }
        )
    }
}

// MARK: - Testing Values

private extension EditCustomFrequencyViewModelTests {

    struct RRuleExpectedModel {
        var frequency: RecurrenceFrequency
        var interval: FrequencyInterval
        var endMode: RecurrenceEndMode
        var endDate: Date = Clock.now
        var occurrenceCount: Int = 0
        var daysOfTheWeek: [Weekday] = []
        var dayOfMonth: DayOfMonth?
        var dayOfYear: DayOfYear?
    }

    struct RRuleUseCase {
        let rule: RecurrenceRule
        let expected: RRuleExpectedModel
    }

    enum TestConstants {
        static let dateNow = Date()
        static let eventDate = Date.make(year: 2024, month: 3, day: 1, hour: 14, minute: 0)

        static var readingUseCases: [RRuleUseCase] {
            return [
                dailyUseCase, weeklyUseCase, monthlyUseCase, monthly2UseCase, yearlyUseCase
            ]
        }

        static let dailyUseCase = RRuleUseCase(
            rule: RecurrenceRule(
                recurrenceWith: .daily,
                interval: 1,
                end: RecurrenceEnd(endDate: eventDate.addDays(30))
            ),
            expected: RRuleExpectedModel(
                frequency: .daily,
                interval: .init(value: 1),
                endMode: .onDate,
                endDate: eventDate.addDays(30)
            )
        )

        static let weeklyUseCase = RRuleUseCase(
            rule: RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 5,
                daysOfTheWeek: [DayOfWeek(.thursday, weekNumber: -1), DayOfWeek(.friday, weekNumber: 0)],
                daysOfTheMonth: [6, 18],
                end: RecurrenceEnd(endDate: eventDate.addDays(20))
            ),
            expected: RRuleExpectedModel(
                frequency: .weekly,
                interval: .init(value: 5),
                endMode: .onDate,
                endDate: eventDate.addDays(20),
                daysOfTheWeek: [.thursday, .friday]
            )
        )

        static let monthlyUseCase = RRuleUseCase(
            rule: RecurrenceRule(
                recurrenceWith: .monthly,
                interval: 2,
                daysOfTheWeek: [DayOfWeek(.sunday, weekNumber: 2), DayOfWeek(.monday, weekNumber: 1)],
                daysOfTheMonth: [6, 18],
                end: RecurrenceEnd(occurrenceCount: 10)
            ),
            expected: RRuleExpectedModel(
                frequency: .monthly,
                interval: .init(value: 2),
                endMode: .afterOccurrences,
                occurrenceCount: 10,
                dayOfMonth: DayOfMonth(weekday: DayOfWeek(.sunday, weekNumber: 2))
            )
        )

        static let monthly2UseCase = RRuleUseCase(
            rule: RecurrenceRule(
                recurrenceWith: .monthly,
                interval: 3,
                daysOfTheMonth: [1, 3, 25],
                end: RecurrenceEnd(occurrenceCount: 10)
            ),
            expected: RRuleExpectedModel(
                frequency: .monthly,
                interval: .init(value: 3),
                endMode: .afterOccurrences,
                occurrenceCount: 10,
                dayOfMonth: DayOfMonth(day: 1)
            )
        )

        static let yearlyUseCase = RRuleUseCase(
            rule: RecurrenceRule(
                recurrenceWith: .yearly,
                interval: 1,
                daysOfTheWeek: [DayOfWeek(.tuesday, weekNumber: 2)],
                daysOfTheMonth: [7, 12],
                monthsOfTheYear: [3, 6],
                end: RecurrenceEnd(occurrenceCount: 5)
            ),
            expected: RRuleExpectedModel(
                frequency: .yearly,
                interval: .init(value: 1),
                endMode: .afterOccurrences,
                occurrenceCount: 5,
                dayOfYear: DayOfYear(day: 7, month: 3)
            )
        )

        static var translatingUseCases: [RRuleUseCase] {
            return [
                weeklyTranslatingUseCase, monthlyTranslatingUseCase, yearlyTranslatingUseCase
            ]
        }

        static let weeklyTranslatingUseCase = RRuleUseCase(
            rule: RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 6,
                daysOfTheWeek: [DayOfWeek(.wednesday), DayOfWeek(.thursday), DayOfWeek(.friday)],
                end: RecurrenceEnd(occurrenceCount: 15)
            ),
            expected: RRuleExpectedModel(
                frequency: .weekly,
                interval: .init(value: 6),
                endMode: .afterOccurrences,
                occurrenceCount: 15,
                daysOfTheWeek: [.wednesday, .thursday, .friday]
            )
        )

        static let monthlyTranslatingUseCase = RRuleUseCase(
            rule: RecurrenceRule(
                recurrenceWith: .monthly,
                interval: 3,
                daysOfTheMonth: [8],
                end: RecurrenceEnd(endDate: dateNow.addDays(30))
            ),
            expected: RRuleExpectedModel(
                frequency: .monthly,
                interval: .init(value: 3),
                endMode: .onDate,
                endDate: dateNow.addDays(30),
                dayOfMonth: DayOfMonth(day: 8)
            )
        )

        static let yearlyTranslatingUseCase = RRuleUseCase(
            rule: RecurrenceRule(
                recurrenceWith: .yearly,
                interval: 1,
                daysOfTheMonth: [9],
                monthsOfTheYear: [5],
                end: RecurrenceEnd(occurrenceCount: 5)
            ),
            expected: RRuleExpectedModel(
                frequency: .yearly,
                interval: .init(value: 1),
                endMode: .afterOccurrences,
                occurrenceCount: 5,
                dayOfYear: DayOfYear(day: 9, month: 5)
            )
        )
    }
}
