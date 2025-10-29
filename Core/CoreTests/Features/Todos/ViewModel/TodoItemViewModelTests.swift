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

    // MARK: - Tests

    func testInitFromPlannableWithValidDate() {
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
        XCTAssertEqual(todoItem?.id, "test-id")
        XCTAssertEqual(todoItem?.type, .assignment)
        XCTAssertEqual(todoItem?.date, date)
        XCTAssertEqual(todoItem?.dateText, date.timeOnlyString)
        XCTAssertEqual(todoItem?.title, "Test Assignment")
        XCTAssertNil(todoItem?.subtitle)
        XCTAssertEqual(todoItem?.contextName, "Test Course")
        XCTAssertEqual(todoItem?.htmlURL, URL(string: "https://example.com"))
    }

    func testInitFromPlannableWithEmptyTitle() {
        // When
        let plannable = makePlannable(plannable: .make(title: nil))
        let todoItem = TodoItemViewModel(plannable)

        // Then
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.title, "")
    }

    func testInitFromPlannableWithDiscussionCheckpointStep() {
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

    func testInitFromPlannableWithRequiredRepliesCheckpointStep() {
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

    func testInitFromPlannableWithPlannerNote() {
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

    func testInitFromPlannableWithPlannerNoteNoContextName() {
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

    func testDirectInit() {
        // When
        let date = Date()
        let url = URL(string: "https://example.com")!
        let todoItem = TodoItemViewModel(
            id: "direct-id",
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
        XCTAssertEqual(todoItem.id, "direct-id")
        XCTAssertEqual(todoItem.type, .quiz)
        XCTAssertEqual(todoItem.date, date)
        XCTAssertEqual(todoItem.dateText, date.timeOnlyString)
        XCTAssertEqual(todoItem.title, "Direct Quiz")
        XCTAssertEqual(todoItem.subtitle, "Test subtitle")
        XCTAssertEqual(todoItem.contextName, "Direct Course")
        XCTAssertEqual(todoItem.htmlURL, url)
        XCTAssertEqual(todoItem.color, .blue)
    }

    func testMakeFactoryMethod() {
        // When
        let date = Date()
        let url = URL(string: "https://example.com")!
        let todoItem = TodoItemViewModel.make(
            id: "factory-id",
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
        XCTAssertEqual(todoItem.id, "factory-id")
        XCTAssertEqual(todoItem.type, .discussion_topic)
        XCTAssertEqual(todoItem.date, date)
        XCTAssertEqual(todoItem.title, "Factory Discussion")
        XCTAssertEqual(todoItem.subtitle, "Factory subtitle")
        XCTAssertEqual(todoItem.contextName, "Factory Course")
        XCTAssertEqual(todoItem.htmlURL, url)
        XCTAssertEqual(todoItem.color, .green)
    }

    func testEquality() {
        // When
        let date = Date()
        let url = URL(string: "https://example.com")!
        let todoItem1 = TodoItemViewModel(
            id: "same-id",
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
            id: "same-id",
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
            id: "different-id",
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

    func testDifferentPlannableTypes() {
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

    func testDateTextProperty() {
        // Given
        let specificDate = Date.make(year: 2025, month: 9, day: 30, hour: 14, minute: 30)

        // When
        let todoItem = TodoItemViewModel(
            id: "datetest-id",
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
