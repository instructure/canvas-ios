//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Core
import XCTest

final class LearnItemModelTests: HorizonTestCase {

    func testInitFromAPIResponse() {
        let item = GetLearnItemsResponse.Item(
            typename: "CourseEnrollmentItemGQL",
            id: "course-1",
            name: "Swift Programming",
            itemType: "COURSE",
            position: 1,
            enrollmentId: "enrollment-1",
            startAt: createDate(year: 2026, month: 1, day: 15),
            endAt: createDate(year: 2026, month: 3, day: 30),
            enrolledAt: "2026-01-01T00:00:00Z",
            completionPercentage: 65.0,
            requirementCount: 10,
            requirementCompletedCount: 6,
            completedAt: nil,
            grade: nil,
            imageURL: URL(string: "https://example.com/image.jpg"),
            workflowState: "active",
            lastActivityAt: nil,
            estimatedDurationMinutes: 180,
            courseCount: nil,
            incompleteModules: nil
        )

        let model = LearnItemModel(item: item)

        XCTAssertEqual(model.id, "course-1")
        XCTAssertEqual(model.name, "Swift Programming")
        XCTAssertEqual(model.completionPercentage, 65.0)
        XCTAssertEqual(model.position, 1)
        XCTAssertEqual(model.startAt, "01/15")
        XCTAssertEqual(model.endAt, "03/30")
        XCTAssertEqual(model.estimatedDurationMinutes, 180)
        XCTAssertEqual(model.itemType, .course)
        XCTAssertEqual(model.enrollmentId, "enrollment-1")
    }

    func testInitFromAPIResponseWithIncompleteModules() {
        let item = GetLearnItemsResponse.Item(
            typename: "CourseEnrollmentItemGQL",
            id: "course-1",
            name: "Course",
            itemType: "COURSE",
            position: 1,
            enrollmentId: "enrollment-1",
            startAt: nil,
            endAt: nil,
            enrolledAt: "2026-01-01T00:00:00Z",
            completionPercentage: 20.0,
            requirementCount: 20,
            requirementCompletedCount: 4,
            completedAt: nil,
            grade: nil,
            imageURL: nil,
            workflowState: "active",
            lastActivityAt: nil,
            estimatedDurationMinutes: 360,
            courseCount: nil,
            incompleteModules: [
                GetLearnItemsResponse.IncompleteModule(
                    id: "module-1",
                    name: "Introduction",
                    incompleteItems: [
                        GetLearnItemsResponse.IncompleteItem(id: "item-1")
                    ]
                )
            ]
        )

        let model = LearnItemModel(item: item)

        XCTAssertEqual(model.nextModuleItemID, "item-1")
    }

    func testEstimatedTimeWithHoursAndMinutes() {
        let model = createModel(estimatedDurationMinutes: 125)

        XCTAssertEqual(model.estimatedTime, "2 hrs 5 mins")
    }

    func testEstimatedTimeWithHoursOnly() {
        let model = createModel(estimatedDurationMinutes: 120)

        XCTAssertEqual(model.estimatedTime, "2 hrs")
    }

    func testEstimatedTimeWithMinutesOnly() {
        let model = createModel(estimatedDurationMinutes: 45)

        XCTAssertEqual(model.estimatedTime, "45 mins")
    }

    func testEstimatedTimeWithNilValue() {
        let model = createModel(estimatedDurationMinutes: nil)

        XCTAssertNil(model.estimatedTime)
    }

    func testButtonCourseTitleBasedOnCompletion() {
        let notStarted = createModel(completionPercentage: 0.0)
        let inProgress = createModel(completionPercentage: 50.0)
        let completed = createModel(completionPercentage: 100.0)

        XCTAssertEqual(notStarted.buttonCourseTitle, "Start learning")
        XCTAssertEqual(inProgress.buttonCourseTitle, "Resume learning")
        XCTAssertEqual(completed.buttonCourseTitle, "View course")
    }

    func testIsCourseCompleted() {
        let completed = createModel(completionPercentage: 100.0)
        let roundedComplete = createModel(completionPercentage: 99.5)
        let notComplete = createModel(completionPercentage: 99.4)

        XCTAssertTrue(completed.isCourseCompleted)
        XCTAssertTrue(roundedComplete.isCourseCompleted)
        XCTAssertFalse(notComplete.isCourseCompleted)
    }

    func testAccessibilityDescriptionForCourse() {
        let model = LearnItemModel(
            id: "item-1",
            name: "Swift Programming",
            completionPercentage: 65.0,
            position: 1,
            startAt: "01/15",
            endAt: "03/30",
            imageUrl: nil,
            estimatedDurationMinutes: 120,
            courseCount: nil,
            itemType: .course
        )

        let description = model.accessibilityLearnDescription

        XCTAssertTrue(description.contains("Course: Swift Programming. "))
        XCTAssertTrue(description.contains("Progress: 65 percent complete. "))
        XCTAssertTrue(description.contains("Estimated duration: 2 hrs. "))
        XCTAssertTrue(description.contains("Date from: 01/15, to: 03/30. "))
    }

    func testAccessibilityDescriptionForProgram() {
        let model = LearnItemModel(
            id: "item-1",
            name: "iOS Development",
            completionPercentage: 30.0,
            position: 1,
            startAt: nil,
            endAt: nil,
            imageUrl: nil,
            estimatedDurationMinutes: nil,
            courseCount: 5,
            itemType: .program
        )

        let description = model.accessibilityLearnDescription

        XCTAssertTrue(description.contains("Program: iOS Development. "))
        XCTAssertTrue(description.contains("Progress: 30 percent complete. "))
        XCTAssertTrue(description.contains("Number of courses: 5 . "))
    }

    func testUIItemTypeNames() {
        XCTAssertEqual(LearnItemModel.UIItemType.all.name, "All")
        XCTAssertEqual(LearnItemModel.UIItemType.course.name, "Courses")
        XCTAssertEqual(LearnItemModel.UIItemType.program.name, "Programs")
    }

    func testUIItemTypeKeys() {
        XCTAssertEqual(LearnItemModel.UIItemType.all.key, "")
        XCTAssertEqual(LearnItemModel.UIItemType.course.key, "COURSE")
        XCTAssertEqual(LearnItemModel.UIItemType.program.key, "PROGRAM")
    }

    func testUIItemTypeAllCases() {
        let allCases = LearnItemModel.UIItemType.allCases

        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.course))
        XCTAssertTrue(allCases.contains(.program))
    }

    private func createModel(
        completionPercentage: Double = 50.0,
        estimatedDurationMinutes: Int? = nil
    ) -> LearnItemModel {
        LearnItemModel(
            id: "item-1",
            name: "Course",
            completionPercentage: completionPercentage,
            position: 1,
            startAt: nil,
            endAt: nil,
            imageUrl: nil,
            estimatedDurationMinutes: estimatedDurationMinutes,
            courseCount: nil,
            itemType: .course
        )
    }

    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
}
