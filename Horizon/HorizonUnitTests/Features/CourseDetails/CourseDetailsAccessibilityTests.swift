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

@testable import Horizon
import HorizonUI
import XCTest

final class CourseDetailsAccessibilityTests: HorizonTestCase {

    // MARK: - ModuleItem Tests

    func testModuleItem_withBasicInfo() {
        let item = HModuleItem(
            id: "1",
            title: "Test Assignment",
            htmlURL: nil,
            dueAt: nil,
        )

        let result = CourseDetailsAccessibility.moduleItem(
            item: item,
            type: .assignment
        )

        XCTAssertEqual(result, "Test Assignment. Type is Assignment. Optional")
    }

    func testModuleItem_withCompletedStatus() {
        let item = HModuleItem(
            id: "1",
            title: "Completed Assignment",
            htmlURL: nil,
            isCompleted: true,
            dueAt: nil
        )

        let result = CourseDetailsAccessibility.moduleItem(
            item: item,
            type: .assignment
        )

        XCTAssertEqual(result, "Completed Assignment. Status is Completed . Type is Assignment. Optional")
    }

    func testModuleItem_withLockedStatus() {
        let item = HModuleItem(
            id: "1",
            title: "Locked Assignment",
            htmlURL: nil,
            dueAt: nil,
            isLocked: true
        )

        let result = CourseDetailsAccessibility.moduleItem(
            item: item,
            type: .assignment
        )
        XCTAssertEqual(result, "Locked Assignment. Status is Locked . Type is Assignment. Optional")
    }

    func testModuleItem_withEstimatedDuration() {
        let item = HModuleItem(
            id: "1",
            title: "Assignment",
            htmlURL: nil,
            dueAt: nil,
            estimatedDuration: "PT3H"
        )

        let result = CourseDetailsAccessibility.moduleItem(
            item: item,
            type: .assignment
        )
        XCTAssertEqual(result, "Assignment. Type is Assignment. Optional. Duration: 3 hours")
    }

    func testModuleItem_withDueDate_notOverdue() {
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = calendar.date(from: DateComponents(
            year: 2025,
            month: 1,
            day: 1,
            hour: 12
        ))!

        // Due date clearly in the future
        let futureDate = calendar.date(byAdding: .day, value: 7, to: referenceDate)!

        let item = HModuleItem(
            id: "1",
            title: "Assignment",
            htmlURL: nil,
            dueAt: futureDate
        )

        // When
        let result = CourseDetailsAccessibility.moduleItem(
            item: item,
            type: .assignment
        )

        // Then
        XCTAssertEqual(result, "Assignment. Type is Assignment. Optional. Past Due date is: 01/08")
    }

    func testModuleItem_withDueDate_overdue() {
        let calendar = Calendar(identifier: .gregorian)
        let pastDate = calendar.date(from: DateComponents(
            year: 2025,
            month: 1,
            day: 1,
            hour: 12
        ))!
        let item = HModuleItem(
            id: "1",
            title: "Assignment",
            htmlURL: nil,
            dueAt: pastDate
        )

        let result = CourseDetailsAccessibility.moduleItem(
            item: item,
            type: .assignment
        )

        XCTAssertEqual(result, "Assignment. Type is Assignment. Optional. Past Due date is: 01/01")
    }

    func testModuleItem_withPoints() {
        let item = HModuleItem(
            id: "1",
            title: "Assignment",
            htmlURL: nil,
            dueAt: nil,
            points: 100.0
        )

        let result = CourseDetailsAccessibility.moduleItem(
            item: item,
            type: .assignment
        )

        XCTAssertEqual(result, "Assignment. Type is Assignment. Optional. Number of points is 100")
    }

    func testModuleItem_withLockedMessage() {
        let item = HModuleItem(
            id: "1",
            title: "Locked Assignment",
            htmlURL: nil,
            dueAt: nil,
            isLocked: true,
            lockExplanation: "This item is locked until you complete the previous module"
        )

        let result = CourseDetailsAccessibility.moduleItem(
            item: item,
            type: .assignment
        )
        XCTAssertEqual(result, "Locked Assignment. Status is Locked . Type is Assignment. Optional")
    }

    func testModuleItem_withDifferentItemTypes() {
        let item = HModuleItem(
            id: "1",
            title: "Test Item",
            htmlURL: nil,
            dueAt: nil
        )

        let quizResult = CourseDetailsAccessibility.moduleItem(item: item, type: .assessment)
        XCTAssertEqual(quizResult, "Test Item. Type is Assessment. Optional")

        let pageResult = CourseDetailsAccessibility.moduleItem(item: item, type: .page)
        XCTAssertEqual(pageResult, "Test Item. Type is Page. Optional")

        let fileResult = CourseDetailsAccessibility.moduleItem(item: item, type: .file)
        XCTAssertEqual(fileResult, "Test Item. Type is File. Optional")
    }

    // MARK: - ModuleContainer Tests

    func testModuleContainer_withBasicInfo() {
        let module = HModule(
            id: "1",
            name: "Module 1",
            courseID: "123",
            items: [.init(id: "1234", title: "Title ", htmlURL: nil, dueAt: nil)]
        )

        let result = CourseDetailsAccessibility.moduleContainer(
            module: module,
            status: .notStarted,
            isCollapsed: false
        )

        XCTAssertEqual(result, "Module 1. Status is Not started. Complete all of the items.. Count of items is 0. Duration is 0 mins. Double tap to Collapsed")
    }

    func testModuleContainer_withNotStartedStatus() {
        let module = HModule(
            id: "1",
            name: "Module 1",
            courseID: "123",
            items: [.init(id: "1234", title: "Title ", htmlURL: nil)]
        )

        let result = CourseDetailsAccessibility.moduleContainer(
            module: module,
            status: .notStarted,
            isCollapsed: false
        )

        XCTAssertEqual(result, "Module 1. Status is Not started. Complete all of the items.. Count of items is 0. Count of past due items is 1. Duration is 0 mins. Double tap to Collapsed")
    }

    func testModuleContainer_withInProgressStatus() {
        let module = HModule(
            id: "1",
            name: "Module 1",
            courseID: "123",
            items: [.init(id: "1234", title: "Title ", htmlURL: nil)]
        )

        let result = CourseDetailsAccessibility.moduleContainer(
            module: module,
            status: .inProgress,
            isCollapsed: false
        )

        XCTAssertEqual(result, "Module 1. Status is In progress. Complete all of the items.. Count of items is 0. Count of past due items is 1. Duration is 0 mins. Double tap to Collapsed")
    }

    func testModuleContainer_withCompletedStatus() {
        let module = HModule(
            id: "1",
            name: "Module 1",
            courseID: "123",
            items: [.init(id: "1234", title: "Title ", htmlURL: nil)]
        )
        let result = CourseDetailsAccessibility.moduleContainer(
            module: module,
            status: .completed,
            isCollapsed: false
        )

        XCTAssertEqual(result, "Module 1. Status is Completed. Complete all of the items.. Count of items is 0. Count of past due items is 1. Duration is 0 mins. Double tap to Collapsed")
    }

    func testModuleContainer_withCollapsedState() {
        let module = HModule(
            id: "1",
            name: "Module 1",
            courseID: "123",
            items: [.init(id: "1234", title: "Title ", htmlURL: nil)]
        )

        let result = CourseDetailsAccessibility.moduleContainer(
            module: module,
            status: .notStarted,
            isCollapsed: true
        )

        XCTAssertEqual(result, "Module 1. Status is Not started. Complete all of the items.. Count of items is 0. Count of past due items is 1. Duration is 0 mins. Double tap to Expanded")
    }

    func testModuleContainer_withExpandedState() {
        let module = HModule(
            id: "1",
            name: "Module 1",
            courseID: "123",
            items: [.init(id: "1234", title: "Title ", htmlURL: nil)]
        )

        let result = CourseDetailsAccessibility.moduleContainer(
            module: module,
            status: .notStarted,
            isCollapsed: false
        )

        XCTAssertEqual(result, "Module 1. Status is Not started. Complete all of the items.. Count of items is 0. Count of past due items is 1. Duration is 0 mins. Double tap to Collapsed")
    }

    func testModuleContainer_withNoDueItems() {
        let module = HModule(
            id: "1",
            name: "Module 1",
            courseID: "123",
            items: [.init(id: "1234", title: "Title ", htmlURL: nil, dueAt: nil)]
        )

        let result = CourseDetailsAccessibility.moduleContainer(
            module: module,
            status: .notStarted,
            isCollapsed: false
        )

        XCTAssertEqual(result, "Module 1. Status is Not started. Complete all of the items.. Count of items is 0. Duration is 0 mins. Double tap to Collapsed")
    }

    func testModuleContainer_accessibilityStrings_areJoinedWithPeriod() {
        let module = HModule(
            id: "1",
            name: "Module 1",
            courseID: "123",
            items: [.init(id: "1234", title: "Title ", htmlURL: nil)]
        )
        let result = CourseDetailsAccessibility.moduleContainer(
            module: module,
            status: .notStarted,
            isCollapsed: false
        )
        XCTAssertTrue(result.contains(". "))
    }
}
