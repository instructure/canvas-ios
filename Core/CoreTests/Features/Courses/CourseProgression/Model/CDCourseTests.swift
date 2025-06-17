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

@testable import Core
import XCTest

class CDCourseTests: CoreTestCase {
    func testAPIResponseSave_completedCourse() {
        let mockEnrollment = GetCoursesProgressionResponse.EnrollmentModel(
            state: "completed",
            id: "enrollment_2",
            course: GetCoursesProgressionResponse.CourseModel(
                id: "course_2",
                name: "Completed Course",
                account: GetCoursesProgressionResponse.AccountModel(name: "Completed Account"),
                imageUrl: "https://example.com/completed.png",
                syllabusBody: "Completed syllabus",
                usersConnection: GetCoursesProgressionResponse.UsersConnection(
                    nodes: [
                        GetCoursesProgressionResponse.NodeModel(
                            courseProgression: GetCoursesProgressionResponse.CourseProgression(
                                requirements: GetCoursesProgressionResponse.Requirements(completionPercentage: 100.0),
                                incompleteModulesConnection: GetCoursesProgressionResponse.IncompleteModulesConnection(nodes: [])
                            )
                        )
                    ]
                ),
                modulesConnection: nil
            )
        )
        let course = CDHCourse.save(mockEnrollment, in: databaseClient)
        XCTAssertEqual(course.completionPercentage, 100.0)
        XCTAssertNil(course.nextModuleID)
        XCTAssertNil(course.nextModuleItemID)
        XCTAssertNil(course.nextModuleItemEstimatedTime)
        XCTAssertNil(course.nextModuleItemType)
        XCTAssertNil(course.nextModuleItemDueDate)
        XCTAssertNil(course.nextModuleName)
        XCTAssertNil(course.nextModuleItemURL)
        XCTAssertNil(course.nextModuleItemName)
    }

    func testAPIResponseSave_nextModuleItemFromIncompleteModules() {
        let dueDate = Date()
        let mockEnrollment = GetCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enrollment_3",
            course: GetCoursesProgressionResponse.CourseModel(
                id: "course_3",
                name: "Active Course",
                account: GetCoursesProgressionResponse.AccountModel(name: "Active Account"),
                imageUrl: "https://example.com/active.png",
                syllabusBody: "Active syllabus",
                usersConnection: GetCoursesProgressionResponse.UsersConnection(
                    nodes: [
                        GetCoursesProgressionResponse.NodeModel(
                            courseProgression: GetCoursesProgressionResponse.CourseProgression(
                                requirements: GetCoursesProgressionResponse.Requirements(completionPercentage: 50.0),
                                incompleteModulesConnection: GetCoursesProgressionResponse.IncompleteModulesConnection(
                                    nodes: [
                                        GetCoursesProgressionResponse.IncompleteNode(
                                            module: GetCoursesProgressionResponse.Module(
                                                id: "module_2",
                                                name: "Module 2",
                                                position: 2
                                            ),
                                            incompleteItemsConnection: GetCoursesProgressionResponse.IncompleteItemsConnection(
                                                nodes: [
                                                    GetCoursesProgressionResponse.ModuleContent(
                                                        url: "https://example.com/item2",
                                                        id: "item_2",
                                                        estimatedDuration: "45m",
                                                        content: GetCoursesProgressionResponse.ContentNode(
                                                            id: "content_2",
                                                            title: "Content 2",
                                                            dueAt: dueDate,
                                                            position: 2.0,
                                                            __typename: "Quiz"
                                                        )
                                                    )
                                                ]
                                            )
                                        )
                                    ]
                                )
                            )
                        )
                    ]
                ),
                modulesConnection: nil
            )
        )
        let course = CDHCourse.save(mockEnrollment, in: databaseClient)
        XCTAssertEqual(course.completionPercentage, 50.0)
        XCTAssertEqual(course.nextModuleID, "module_2")
        XCTAssertEqual(course.nextModuleItemID, "item_2")
        XCTAssertEqual(course.nextModuleItemEstimatedTime, "45m")
        XCTAssertEqual(course.nextModuleItemType, "Quiz")
        XCTAssertEqual(course.nextModuleItemDueDate, dueDate)
        XCTAssertEqual(course.nextModuleName, "Module 2")
        XCTAssertEqual(course.nextModuleItemURL, "https://example.com/item2")
        XCTAssertEqual(course.nextModuleItemName, "Content 2")
    }

    func testAPIResponseSave_nextModuleItemFromModulesConnection() {
        let dueDate = Date()
        let mockEnrollment = GetCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enrollment_4",
            course: GetCoursesProgressionResponse.CourseModel(
                id: "course_4",
                name: "Not Started Course",
                account: GetCoursesProgressionResponse.AccountModel(name: "Not Started Account"),
                imageUrl: "https://example.com/notstarted.png",
                syllabusBody: "Not started syllabus",
                usersConnection: GetCoursesProgressionResponse.UsersConnection(
                    nodes: [
                        GetCoursesProgressionResponse.NodeModel(
                            courseProgression: GetCoursesProgressionResponse.CourseProgression(
                                requirements: GetCoursesProgressionResponse.Requirements(completionPercentage: 0.0),
                                incompleteModulesConnection: GetCoursesProgressionResponse.IncompleteModulesConnection(nodes: [])
                            )
                        )
                    ]
                ),
                modulesConnection: GetCoursesProgressionResponse.ModulesConnection(
                    edges: [
                        GetCoursesProgressionResponse.ModulesConnection.Edge(
                            node: GetCoursesProgressionResponse.ModulesConnection.Node(
                                id: "module_3",
                                name: "Module 3",
                                moduleItems: [
                                    GetCoursesProgressionResponse.ModulesConnection.ModuleItem(
                                        id: "item_3",
                                        estimatedDuration: "60m",
                                        url: "https://example.com/item3",
                                        content: GetCoursesProgressionResponse.ModulesConnection.Content(
                                            id: "content_3",
                                            title: "Content 3",
                                            __typename: "Assignment",
                                            dueAt: dueDate
                                        )
                                    )
                                ]
                            )
                        )
                    ]
                )
            )
        )
        let course = CDHCourse.save(mockEnrollment, in: databaseClient)
        XCTAssertEqual(course.completionPercentage, 0.0)
        XCTAssertEqual(course.nextModuleID, "module_3")
        XCTAssertEqual(course.nextModuleItemID, "content_3")
        XCTAssertEqual(course.nextModuleItemEstimatedTime, "60m")
        XCTAssertEqual(course.nextModuleItemType, "Assignment")
        XCTAssertEqual(course.nextModuleItemDueDate, dueDate)
        XCTAssertEqual(course.nextModuleName, "Module 3")
        XCTAssertEqual(course.nextModuleItemURL, "https://example.com/item3")
        XCTAssertEqual(course.nextModuleItemName, "Content 3")
    }
}
