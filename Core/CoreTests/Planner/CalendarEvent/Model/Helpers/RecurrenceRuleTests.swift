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

final class RecurrenceRuleTests: XCTestCase {

    func test_intialization() {
        for useCase in TestConstants.useCases {
            let parsedRule = RecurrenceRule(rruleDescription: useCase.raw)
            XCTAssertEqual(useCase.rule, parsedRule)
            XCTAssertEqual(useCase.text, parsedRule?.text)
        }
    }

    func test_generation() {
        for useCase in TestConstants.useCases {
            XCTAssertEqual(useCase.rule.rruleDescription, useCase.raw)
        }
    }

    func test_encoding() throws {
        let encoder = JSONEncoder()
        for useCase in TestConstants.useCases {
            let data = try encoder.encode(useCase.rule)
            let string = try XCTUnwrap(String(data: data, encoding: .utf8))
            XCTAssertEqual(string, "\"\(useCase.raw)\"")
        }
    }

    func test_decoding() throws {
        let decoder = JSONDecoder()
        for useCase in TestConstants.useCases {
            let data = try XCTUnwrap("\"\(useCase.raw)\"".data(using: .utf8))
            let rule = try decoder.decode(RecurrenceRule.self, from: data)
            XCTAssertEqual(useCase.rule, rule)
        }
    }
}

private enum TestConstants {
    struct UseCase {
        let raw: String
        let rule: RecurrenceRule
        let text: String
    }

    static let date = Date.make(year: 2024, month: 3, day: 1, hour: 14, minute: 0)

    static let useCases: [UseCase] = [

        // Daily
        UseCase(
            raw: "RRULE:FREQ=DAILY;INTERVAL=3;COUNT=32",
            rule: RecurrenceRule(
                recurrenceWith: .daily,
                interval: 3,
                end: .occurrenceCount(32)
            ),
            text: "Every 3rd day, 32 times"
        ),
        UseCase(
            raw: "RRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20240927T000000Z",
            rule: RecurrenceRule(
                recurrenceWith: .daily,
                interval: 1,
                end: .endDate(.make(year: 2024, month: 9, day: 27))
            ),
            text: "Daily, until Sep 27, 2024"
        ),

        // Weekly
        UseCase(
            raw: "RRULE:FREQ=WEEKLY;INTERVAL=4;BYDAY=MO,WE,FR;COUNT=11",
            rule: RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 4,
                daysOfTheWeek: [
                    DayOfWeek(.monday), DayOfWeek(.wednesday), DayOfWeek(.friday)
                ],
                end: .occurrenceCount(11)
            ),
            text: "Every 4th week on Monday, Wednesday, Friday, 11 times"
        ),
        UseCase(
            raw: "RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TU,WE,TH,FR;UNTIL=20240916T000000Z",
            rule: RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 2,
                daysOfTheWeek: [
                    DayOfWeek(.monday), DayOfWeek(.tuesday),
                    DayOfWeek(.wednesday), DayOfWeek(.thursday),
                    DayOfWeek(.friday)
                ],
                end: .endDate(.make(year: 2024, month: 9, day: 16))
            ),
            text: "Every other week on Every Weekday, until Sep 16, 2024"
        ),
        UseCase(
            raw: "RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR;UNTIL=20240808T000000Z",
            rule: RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: [
                    DayOfWeek(.monday), DayOfWeek(.tuesday),
                    DayOfWeek(.wednesday), DayOfWeek(.thursday),
                    DayOfWeek(.friday)
                ],
                end: .endDate(.make(year: 2024, month: 8, day: 8))
            ),
            text: "Every Weekday, until Aug 8, 2024"
        ),

        // Monthly
        UseCase(
            raw: "RRULE:FREQ=MONTHLY;INTERVAL=1;BYDAY=1MO,2SU,3SA;COUNT=8",
            rule: RecurrenceRule(
                recurrenceWith: .monthly,
                interval: 1,
                daysOfTheWeek: [
                    DayOfWeek(.monday, weekNumber: 1),
                    DayOfWeek(.sunday, weekNumber: 2),
                    DayOfWeek(.saturday, weekNumber: 3)
                ],
                end: .occurrenceCount(8)
            ),
            text: "Monthly on The First Monday, The Second Sunday, The Third Saturday, 8 times"
        ),
        UseCase(
            raw: "RRULE:FREQ=MONTHLY;INTERVAL=3;BYMONTHDAY=4,8,18;UNTIL=20241219T000000Z",
            rule: RecurrenceRule(
                recurrenceWith: .monthly,
                interval: 3,
                daysOfTheMonth: [4, 8, 18],
                end: .endDate(.make(year: 2024, month: 12, day: 19))
            ),
            text: "Every 3rd month on Day 4, Day 8, Day 18, until Dec 19, 2024"
        ),

        // Yearly
        UseCase(
            raw: "RRULE:FREQ=YEARLY;INTERVAL=6;BYMONTH=9;BYDAY=2FR,4SA,5TU,-1TH;UNTIL=20250522T000000Z",
            rule: RecurrenceRule(
                recurrenceWith: .yearly,
                interval: 6,
                daysOfTheWeek: [
                    DayOfWeek(.friday, weekNumber: 2),
                    DayOfWeek(.saturday, weekNumber: 4),
                    DayOfWeek(.tuesday, weekNumber: 5),
                    DayOfWeek(.thursday, weekNumber: -1)
                ],
                monthsOfTheYear: [9],
                end: .endDate(.make(year: 2025, month: 5, day: 22))
            ),
            text: "Every 6th year on September, The Second Friday, The Fourth Saturday, The Fifth Tuesday, The Last Thursday, until May 22, 2025"
        ),
        UseCase(
            raw: "RRULE:FREQ=YEARLY;INTERVAL=2;BYMONTH=11;BYMONTHDAY=3,5,6,9;COUNT=5",
            rule: RecurrenceRule(
                recurrenceWith: .yearly,
                interval: 2,
                daysOfTheMonth: [3, 5, 6, 9],
                monthsOfTheYear: [11],
                end: .occurrenceCount(5)
            ),
            text: "Every other year on November, Day 3, Day 5, Day 6, Day 9, 5 times"
        )
    ]
}
