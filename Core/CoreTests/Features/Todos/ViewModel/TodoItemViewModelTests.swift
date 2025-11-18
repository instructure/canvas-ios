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
import TestsFoundation
import SwiftUI

class TodoItemViewModelTests: CoreTestCase {

    // MARK: - Initialization Tests

    func test_init_setsPropertiesFromPlannable() {
        // When
        let date = Date()
        let plannable = makePlannable(
            plannableId: "test-id",
            plannableType: "assignment",
            htmlURL: URL(string: "https://example.com")!,
            contextName: "Test Course",
            plannable: .make(title: "Test Assignment"),
            plannableDate: date
        )
        let todoItem = TodoItemViewModel(plannable)

        // Then
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.plannableId, "test-id")
        XCTAssertEqual(todoItem?.type, .assignment)
        XCTAssertEqual(todoItem?.date, date)
        XCTAssertEqual(todoItem?.dateText, date.timeOnlyString)
        XCTAssertEqual(todoItem?.title, "Test Assignment")
        XCTAssertNil(todoItem?.subtitle)
        XCTAssertEqual(todoItem?.contextName, "Test Course")
        XCTAssertEqual(todoItem?.htmlURL, URL(string: "https://example.com"))
    }

    func test_init_handlesEmptyTitle() {
        // When
        let plannable = makePlannable(plannable: .make(title: nil))
        let todoItem = TodoItemViewModel(plannable)

        // Then
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.title, "")
    }

    func test_init_setsDiscussionCheckpointSubtitle() {
        // When
        let plannable = makePlannable(
            plannableType: "sub_assignment",
            plannable: .make(
                title: "Discussion Reply",
                sub_assignment_tag: "reply_to_topic"
            ),
            details: .make(reply_to_entry_required_count: nil)
        )
        plannable.discussionCheckpointStep = .replyToTopic
        let todoItem = TodoItemViewModel(plannable)

        // Then
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.subtitle, "Reply to topic")
    }

    func test_init_setsRequiredRepliesSubtitle() {
        // When
        let plannable = makePlannable(
            plannableType: "sub_assignment",
            plannable: .make(
                title: "Discussion Reply",
                sub_assignment_tag: "reply_to_entry"
            ),
            details: .make(reply_to_entry_required_count: 3)
        )
        plannable.discussionCheckpointStep = .requiredReplies(3)
        let todoItem = TodoItemViewModel(plannable)

        // Then
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.subtitle, "Additional replies (3)")
    }

    func test_init_formatsPlannerNoteContextName() {
        // When
        let plannable = makePlannable(
            plannableType: "planner_note",
            contextName: "Math 101",
            plannable: .make(title: "Study for exam")
        )
        let todoItem = TodoItemViewModel(plannable)

        // Then
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.type, .planner_note)
        XCTAssertEqual(todoItem?.contextName, "Math 101 To-do")
    }

    func test_init_handlesPlannerNoteWithoutContextName() {
        // When
        let plannable = makePlannable(
            plannableType: "planner_note",
            contextName: nil,
            plannable: .make(title: "Personal note")
        )
        let todoItem = TodoItemViewModel(plannable)

        // Then
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.contextName, "To-do")
    }

    func test_init_setsPropertiesDirectly() {
        // When
        let date = Date()
        let url = URL(string: "https://example.com")!
        let todoItem = TodoItemViewModel(
            plannableId: "direct-id",
            type: .quiz,
            date: date,
            title: "Direct Quiz",
            subtitle: "Test subtitle",
            contextName: "Direct Course",
            htmlURL: url,
            color: .blue,
            icon: .quizLine
        )

        // Then
        XCTAssertEqual(todoItem.plannableId, "direct-id")
        XCTAssertEqual(todoItem.type, .quiz)
        XCTAssertEqual(todoItem.date, date)
        XCTAssertEqual(todoItem.dateText, date.timeOnlyString)
        XCTAssertEqual(todoItem.title, "Direct Quiz")
        XCTAssertEqual(todoItem.subtitle, "Test subtitle")
        XCTAssertEqual(todoItem.contextName, "Direct Course")
        XCTAssertEqual(todoItem.htmlURL, url)
        XCTAssertEqual(todoItem.color, .blue)
    }

    // MARK: - Factory Methods

    func test_make_createsInstanceWithFactoryMethod() {
        // When
        let date = Date()
        let url = URL(string: "https://example.com")!
        let todoItem = TodoItemViewModel.make(
            plannableId: "factory-id",
            type: .discussion_topic,
            date: date,
            title: "Factory Discussion",
            subtitle: "Factory subtitle",
            contextName: "Factory Course",
            htmlURL: url,
            color: .green,
            icon: .discussionLine
        )

        // Then
        XCTAssertEqual(todoItem.plannableId, "factory-id")
        XCTAssertEqual(todoItem.type, .discussion_topic)
        XCTAssertEqual(todoItem.date, date)
        XCTAssertEqual(todoItem.title, "Factory Discussion")
        XCTAssertEqual(todoItem.subtitle, "Factory subtitle")
        XCTAssertEqual(todoItem.contextName, "Factory Course")
        XCTAssertEqual(todoItem.htmlURL, url)
        XCTAssertEqual(todoItem.color, .green)
    }

    // MARK: - Equatable & Comparable

    func test_equatable_comparesCorrectly() {
        // When
        let date = Date()
        let url = URL(string: "https://example.com")!
        let todoItem1 = TodoItemViewModel(
            plannableId: "same-id",
            type: .assignment,
            date: date,
            title: "Same Title",
            subtitle: "Same subtitle",
            contextName: "Same Course",
            htmlURL: url,
            color: .blue,
            icon: .assignmentLine
        )

        let todoItem2 = TodoItemViewModel(
            plannableId: "same-id",
            type: .assignment,
            date: date,
            title: "Same Title",
            subtitle: "Same subtitle",
            contextName: "Same Course",
            htmlURL: url,
            color: .blue,
            icon: .assignmentLine
        )

        let todoItem3 = TodoItemViewModel(
            plannableId: "different-id",
            type: .assignment,
            date: date,
            title: "Same Title",
            subtitle: "Same subtitle",
            contextName: "Same Course",
            htmlURL: url,
            color: .blue,
            icon: .assignmentLine
        )

        // Then
        XCTAssertEqual(todoItem1, todoItem2)
        XCTAssertNotEqual(todoItem1, todoItem3)
    }

    func test_init_handlesAllPlannableTypes() {
        // Given
        let allTypes: [PlannableType] = [
            .announcement,
            .assignment,
            .discussion_topic,
            .quiz,
            .wiki_page,
            .planner_note,
            .calendar_event,
            .assessment_request,
            .sub_assignment,
            .other
        ]

        for type in allTypes {
            // When
            let todoItem = TodoItemViewModel(makePlannable(plannableType: type.rawValue))

            // Then
            XCTAssertNotNil(todoItem)
            XCTAssertEqual(todoItem?.type, type)
        }
    }

    func test_dateText_formatsCorrectly() {
        // Given
        let specificDate = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)

        // When
        let todoItem = TodoItemViewModel(
            plannableId: "datetest-id",
            type: .assignment,
            date: specificDate,
            title: "Date Test Assignment",
            subtitle: nil,
            contextName: "Test Course",
            htmlURL: nil,
            color: .blue,
            icon: .assignmentLine
        )

        // Then
        XCTAssertEqual(todoItem.dateText, specificDate.timeOnlyString)
        XCTAssertEqual(todoItem.date, specificDate)
    }

    // MARK: - Date Formatting Tests

    func test_formatDateText_returnsAllDay_whenIsAllDayIsTrue() {
        // GIVEN
        let date = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)

        // WHEN
        let result = TodoItemViewModel.formatDateText(date: date, isAllDay: true, endAt: nil)

        // THEN
        XCTAssertEqual(result, "All Day")
    }

    func test_formatDateText_returnsTimeRange_whenEndAtIsProvided() {
        // GIVEN
        let startDate = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)
        let endDate = Date.make(year: 2025, month: 9, day: 30, hour: 16, minute: 0)

        // WHEN
        let result = TodoItemViewModel.formatDateText(date: startDate, isAllDay: false, endAt: endDate)

        // THEN
        XCTAssertEqual(result, startDate.timeIntervalString(to: endDate))
    }

    func test_formatDateText_returnsSingleTime_whenNotAllDayAndNoEndDate() {
        // GIVEN
        let date = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)

        // WHEN
        let result = TodoItemViewModel.formatDateText(date: date, isAllDay: false, endAt: nil)

        // THEN
        XCTAssertEqual(result, date.timeOnlyString)
    }

    func test_formatDateText_prioritizesAllDay_overEndAt() {
        // GIVEN
        let startDate = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)
        let endDate = Date.make(year: 2025, month: 9, day: 30, hour: 16, minute: 0)

        // WHEN
        let result = TodoItemViewModel.formatDateText(date: startDate, isAllDay: true, endAt: endDate)

        // THEN
        XCTAssertEqual(result, "All Day")
    }

    func test_init_withPlannable_setsAllDayDateText() {
        // GIVEN
        let date = Date.make(year: 2025, month: 9, day: 30, hour: 0, minute: 0)
        let plannable = Plannable.save(
            APIPlannable.make(
                plannable: .make(
                    title: "All Day Event",
                    all_day: true,
                    start_at: date,
                    end_at: nil
                ),
                plannable_date: date
            ),
            userId: nil,
            in: databaseClient
        )

        // WHEN
        let todoItem = TodoItemViewModel(plannable)

        // THEN
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.dateText, "All Day")
    }

    func test_init_withPlannable_setsTimeRangeDateText() {
        // GIVEN
        let startDate = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)
        let endDate = Date.make(year: 2025, month: 9, day: 30, hour: 16, minute: 0)
        let plannable = Plannable.save(
            APIPlannable.make(
                plannable: .make(
                    title: "Time Range Event",
                    all_day: false,
                    start_at: startDate,
                    end_at: endDate
                ),
                plannable_date: startDate
            ),
            userId: nil,
            in: databaseClient
        )

        // WHEN
        let todoItem = TodoItemViewModel(plannable)

        // THEN
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.dateText, startDate.timeIntervalString(to: endDate))
    }

    func test_init_withPlannable_setsSingleTimeDateText() {
        // GIVEN
        let date = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)
        let plannable = Plannable.save(
            APIPlannable.make(
                plannable: .make(
                    title: "Single Time Event",
                    all_day: false,
                    start_at: date,
                    end_at: nil
                ),
                plannable_date: date
            ),
            userId: nil,
            in: databaseClient
        )

        // WHEN
        let todoItem = TodoItemViewModel(plannable)

        // THEN
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.dateText, date.timeOnlyString)
    }

    func test_init_withDirectParams_setsAllDayDateText() {
        // GIVEN
        let date = Date.make(year: 2025, month: 9, day: 30, hour: 0, minute: 0)

        // WHEN
        let todoItem = TodoItemViewModel(
            plannableId: "all-day-id",
            type: .calendar_event,
            date: date,
            title: "All Day Event",
            subtitle: nil,
            contextName: "Test Course",
            htmlURL: nil,
            color: .blue,
            icon: .calendarMonthLine,
            isAllDay: true
        )

        // THEN
        XCTAssertEqual(todoItem.dateText, "All Day")
    }

    func test_init_withDirectParams_setsTimeRangeDateText() {
        // GIVEN
        let startDate = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)
        let endDate = Date.make(year: 2025, month: 9, day: 30, hour: 16, minute: 0)

        // WHEN
        let todoItem = TodoItemViewModel(
            plannableId: "time-range-id",
            type: .calendar_event,
            date: startDate,
            title: "Time Range Event",
            subtitle: nil,
            contextName: "Test Course",
            htmlURL: nil,
            color: .blue,
            icon: .calendarMonthLine,
            endAt: endDate
        )

        // THEN
        XCTAssertEqual(todoItem.dateText, startDate.timeIntervalString(to: endDate))
    }

    // MARK: - Mark As Done State

    func test_markAsDoneState_initializesToNotDone_whenPlannableIsNotComplete() {
        // GIVEN
        let plannable = Plannable.save(
            APIPlannable.make(plannable_id: ID("1")),
            userId: nil,
            in: databaseClient
        )

        // WHEN
        let todoItem = TodoItemViewModel(plannable)

        // THEN
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.markAsDoneState, .notDone)
    }

    func test_markAsDoneState_initializesToDone_whenPlannableIsComplete() {
        // GIVEN
        let plannable = Plannable.save(
            APIPlannable.make(
                planner_override: .make(id: "override-1", marked_complete: true),
                plannable_id: ID("1")
            ),
            userId: nil,
            in: databaseClient
        )

        // WHEN
        let todoItem = TodoItemViewModel(plannable)

        // THEN
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.markAsDoneState, .done)
    }

    // MARK: - Swipe Properties

    func test_swipeProperties_initializeWithNotDoneState() {
        // GIVEN
        let plannable = Plannable.save(
            APIPlannable.make(plannable_id: ID("1")),
            userId: nil,
            in: databaseClient
        )

        // WHEN
        let todoItem = TodoItemViewModel(plannable)

        // THEN
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.swipeBackgroundColor, .backgroundSuccess)
        XCTAssertEqual(todoItem?.swipeActionText, "Done")
        XCTAssertEqual(todoItem?.swipeActionIcon, .checkLine)
    }

    func test_swipeProperties_updateWhenMarkAsDoneStateChangesToDone() {
        // GIVEN
        let todoItem = TodoItemViewModel.make(plannableId: "1")
        XCTAssertEqual(todoItem.swipeBackgroundColor, .backgroundSuccess)

        // WHEN
        todoItem.markAsDoneState = .done

        // THEN
        XCTAssertEqual(todoItem.swipeBackgroundColor, .backgroundDark)
        XCTAssertEqual(todoItem.swipeActionText, "Undo")
        XCTAssertEqual(todoItem.swipeActionIcon, .discussionReply2Line)
    }

    func test_swipeProperties_updateWhenMarkAsDoneStateChangesToNotDone() {
        // GIVEN
        let todoItem = TodoItemViewModel.make(plannableId: "1")
        todoItem.markAsDoneState = .done
        XCTAssertEqual(todoItem.swipeBackgroundColor, .backgroundDark)

        // WHEN
        todoItem.markAsDoneState = .notDone

        // THEN
        XCTAssertEqual(todoItem.swipeBackgroundColor, .backgroundSuccess)
        XCTAssertEqual(todoItem.swipeActionText, "Done")
        XCTAssertEqual(todoItem.swipeActionIcon, .checkLine)
    }

    func test_swipeProperties_updateDuringLoadingState() {
        // GIVEN
        let todoItem = TodoItemViewModel.make(plannableId: "1")
        todoItem.markAsDoneState = .done
        XCTAssertEqual(todoItem.swipeBackgroundColor, .backgroundDark)

        // WHEN
        todoItem.markAsDoneState = .loading

        // THEN
        XCTAssertEqual(todoItem.swipeBackgroundColor, .backgroundSuccess)
        XCTAssertEqual(todoItem.swipeActionText, "Done")
        XCTAssertEqual(todoItem.swipeActionIcon, .checkLine)
    }

    func test_swipeProperties_initializeCorrectlyWithDoneState() {
        // GIVEN
        let plannable = Plannable.save(
            APIPlannable.make(
                planner_override: .make(id: "override-1", marked_complete: true),
                plannable_id: ID("1")
            ),
            userId: nil,
            in: databaseClient
        )

        // WHEN
        let todoItem = TodoItemViewModel(plannable)

        // THEN
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.swipeBackgroundColor, .backgroundDark)
        XCTAssertEqual(todoItem?.swipeActionText, "Undo")
        XCTAssertEqual(todoItem?.swipeActionIcon, .discussionReply2Line)
    }

    // MARK: - Helpers

    private func makePlannable(
        plannableId: String = "test-id",
        plannableType: String = "assignment",
        htmlURL: URL = .init(string: "https://example.com")!,
        contextName: String? = nil,
        plannable: APIPlannable.Plannable = .make(title: "Test Assignment"),
        plannableDate: Date = .now,
        details: APIPlannable.Details? = nil
    ) -> Plannable {
        return Plannable.make(from: makeApiPlannable(
            plannableId: plannableId,
            plannableType: plannableType,
            htmlURL: htmlURL,
            contextName: contextName,
            plannable: plannable,
            plannableDate: plannableDate,
            details: details
        ), in: databaseClient)
    }

    private func makeApiPlannable(
        plannableId: String,
        plannableType: String,
        htmlURL: URL,
        contextName: String?,
        plannable: APIPlannable.Plannable,
        plannableDate: Date,
        details: APIPlannable.Details?
    ) -> APIPlannable {
        .make(
            plannable_id: ID(plannableId),
            plannable_type: plannableType,
            html_url: htmlURL,
            context_name: contextName,
            plannable: plannable,
            plannable_date: plannableDate,
            details: details
        )
    }
}
