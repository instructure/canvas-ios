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

import XCTest
@testable import Core

final class DueDateSummaryTests: CoreTestCase {

    private static let testData = (
        dateNow: Date.make(year: 2025, month: 1, day: 15, hour: 12),
        dateFuture: Date.make(year: 2025, month: 2, day: 1),
        datePast: Date.make(year: 2024, month: 12, day: 1),
        lockDateFuture: Date.make(year: 2025, month: 3, day: 1),
        lockDatePast: Date.make(year: 2024, month: 11, day: 1)
    )
    private lazy var testData = Self.testData

    override func setUp() {
        super.setUp()
        Clock.mockNow(testData.dateNow)
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_whenNoDueDateAndNoLockDateAndNoOverrides_shouldReturnNoDueDate() {
        let testee = DueDateSummary(nil, lockDate: nil, hasOverrides: false)

        XCTAssertEqual(testee, .noDueDate)
    }

    func test_init_whenDueDateAndNoLockDateAndNoOverrides_shouldReturnDueDate() {
        let testee = DueDateSummary(testData.dateFuture, lockDate: nil, hasOverrides: false)

        XCTAssertEqual(testee, .dueDate(testData.dateFuture))
    }

    func test_init_whenNoOverridesAndLockDateInFuture_shouldReturnDueDate() {
        let testee = DueDateSummary(testData.dateFuture, lockDate: testData.lockDateFuture, hasOverrides: false)

        XCTAssertEqual(testee, .dueDate(testData.dateFuture))
    }

    func test_init_whenNoOverridesAndLockDateInPast_shouldReturnAvailabilityClosed() {
        let testee = DueDateSummary(testData.dateFuture, lockDate: testData.lockDatePast, hasOverrides: false)

        XCTAssertEqual(testee, .availabilityClosed)
    }

    func test_init_whenNoOverridesAndLockDateEqualsNow_shouldReturnDueDate() {
        let testee = DueDateSummary(testData.dateFuture, lockDate: testData.dateNow, hasOverrides: false)

        XCTAssertEqual(testee, .dueDate(testData.dateFuture))
    }

    func test_init_whenNoOverridesAndLockDateJustAfterNow_shouldReturnAvailabilityClosed() {
        let lockDateJustAfterNow = testData.dateNow.addMinutes(1)
        Clock.mockNow(lockDateJustAfterNow.addMinutes(1))

        let testee = DueDateSummary(testData.dateFuture, lockDate: lockDateJustAfterNow, hasOverrides: false)

        XCTAssertEqual(testee, .availabilityClosed)
    }

    func test_init_whenHasOverridesAndNoLockDate_shouldReturnMultipleDueDates() {
        let testee = DueDateSummary(testData.dateFuture, lockDate: nil, hasOverrides: true)

        XCTAssertEqual(testee, .multipleDueDates)
    }

    func test_init_whenHasOverridesAndLockDateInFuture_shouldReturnMultipleDueDates() {
        let testee = DueDateSummary(testData.dateFuture, lockDate: testData.lockDateFuture, hasOverrides: true)

        XCTAssertEqual(testee, .multipleDueDates)
    }

    func test_init_whenHasOverridesAndLockDateInPast_shouldReturnAvailabilityClosed() {
        let testee = DueDateSummary(testData.dateFuture, lockDate: testData.lockDatePast, hasOverrides: true)

        XCTAssertEqual(testee, .availabilityClosed)
    }

    func test_init_whenNoDueDateAndHasOverrides_shouldReturnMultipleDueDates() {
        let testee = DueDateSummary(nil, lockDate: nil, hasOverrides: true)

        XCTAssertEqual(testee, .multipleDueDates)
    }

    func test_init_whenNoDueDateAndLockDateInPast_shouldReturnAvailabilityClosed() {
        let testee = DueDateSummary(nil, lockDate: testData.lockDatePast, hasOverrides: false)

        XCTAssertEqual(testee, .availabilityClosed)
    }

    // MARK: - Text Property

    func test_text_whenNoDueDate_shouldReturnFormattedText() {
        let testee = DueDateSummary.noDueDate

        XCTAssertEqual(testee.text, DueDateFormatter.noDueDateText)
    }

    func test_text_whenDueDate_shouldReturnFormattedTextWithPrefix() {
        let testee = DueDateSummary.dueDate(testData.dateFuture)

        XCTAssertEqual(testee.text, DueDateFormatter.dateText(testData.dateFuture))
    }

    func test_text_whenAvailabilityClosed_shouldReturnFormattedText() {
        let testee = DueDateSummary.availabilityClosed

        XCTAssertEqual(testee.text, DueDateFormatter.availabilityClosedText)
    }

    func test_text_whenMultipleDueDates_shouldReturnFormattedText() {
        let testee = DueDateSummary.multipleDueDates

        XCTAssertEqual(testee.text, DueDateFormatter.multipleDueDatesText)
    }

    // MARK: - Text Without Prefix Property

    func test_textWithoutPrefix_whenNoDueDate_shouldReturnFormattedText() {
        let testee = DueDateSummary.noDueDate

        XCTAssertEqual(testee.textWithoutPrefix, DueDateFormatter.noDueDateText)
    }

    func test_textWithoutPrefix_whenDueDate_shouldReturnFormattedTextWithoutPrefix() {
        let testee = DueDateSummary.dueDate(testData.dateFuture)

        XCTAssertEqual(testee.textWithoutPrefix, DueDateFormatter.dateTextWithoutDue(testData.dateFuture))
    }

    func test_textWithoutPrefix_whenAvailabilityClosed_shouldReturnFormattedText() {
        let testee = DueDateSummary.availabilityClosed

        XCTAssertEqual(testee.textWithoutPrefix, DueDateFormatter.availabilityClosedText)
    }

    func test_textWithoutPrefix_whenMultipleDueDates_shouldReturnFormattedText() {
        let testee = DueDateSummary.multipleDueDates

        XCTAssertEqual(testee.textWithoutPrefix, DueDateFormatter.multipleDueDatesText)
    }

    // MARK: - Array Extension - reduceIfNeeded

    func test_reduceIfNeeded_whenContainsAvailabilityClosed_shouldReturnOnlyAvailabilityClosed() {
        let array: [DueDateSummary] = [
            .noDueDate,
            .dueDate(testData.dateFuture),
            .availabilityClosed,
            .multipleDueDates
        ]

        let result = array.reduceIfNeeded()

        XCTAssertEqual(result, [.availabilityClosed])
    }

    func test_reduceIfNeeded_whenContainsMultipleDueDatesButNoAvailabilityClosed_shouldReturnOnlyMultipleDueDates() {
        let array: [DueDateSummary] = [
            .noDueDate,
            .dueDate(testData.dateFuture),
            .multipleDueDates,
            .dueDate(testData.datePast)
        ]

        let result = array.reduceIfNeeded()

        XCTAssertEqual(result, [.multipleDueDates])
    }

    func test_reduceIfNeeded_whenContainsOnlyNoDueDateAndDueDate_shouldReturnOriginalArray() {
        let array: [DueDateSummary] = [
            .noDueDate,
            .dueDate(testData.dateFuture),
            .dueDate(testData.datePast)
        ]

        let result = array.reduceIfNeeded()

        XCTAssertEqual(result, array)
    }

    func test_reduceIfNeeded_whenEmptyArray_shouldReturnEmptyArray() {
        let array: [DueDateSummary] = []

        let result = array.reduceIfNeeded()

        XCTAssertEqual(result, [])
    }

    func test_reduceIfNeeded_whenSingleElement_shouldReturnOriginalArray() {
        let array: [DueDateSummary] = [.dueDate(testData.dateFuture)]

        let result = array.reduceIfNeeded()

        XCTAssertEqual(result, array)
    }

    func test_reduceIfNeeded_whenOnlyAvailabilityClosed_shouldReturnSameArray() {
        let array: [DueDateSummary] = [.availabilityClosed]

        let result = array.reduceIfNeeded()

        XCTAssertEqual(result, [.availabilityClosed])
    }

    func test_reduceIfNeeded_whenOnlyMultipleDueDates_shouldReturnSameArray() {
        let array: [DueDateSummary] = [.multipleDueDates]

        let result = array.reduceIfNeeded()

        XCTAssertEqual(result, [.multipleDueDates])
    }
}
