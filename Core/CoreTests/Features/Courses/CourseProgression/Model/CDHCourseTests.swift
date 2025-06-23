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

class CDHCourseTests: CoreTestCase {
    func testAPIResponseSave_completedCourse() {
        let mockEnrollment = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "completed",
            id: "enrollment_2",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course_2",
                name: "Completed Course",
                account: GetHCoursesProgressionResponse.AccountModel(name: "Completed Account"),
                imageUrl: "https://example.com/completed.png",
                syllabusBody: "Completed syllabus",
                usersConnection: GetHCoursesProgressionResponse.UsersConnection(
                    nodes: [
                        GetHCoursesProgressionResponse.NodeModel(
                            courseProgression: GetHCoursesProgressionResponse.CourseProgression(
                                requirements: GetHCoursesProgressionResponse.Requirements(completionPercentage: 100.0),
                                incompleteModulesConnection: GetHCoursesProgressionResponse.IncompleteModulesConnection(nodes: [])
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
        let mockEnrollment = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enrollment_3",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course_3",
                name: "Active Course",
                account: GetHCoursesProgressionResponse.AccountModel(name: "Active Account"),
                imageUrl: "https://example.com/active.png",
                syllabusBody: "Active syllabus",
                usersConnection: GetHCoursesProgressionResponse.UsersConnection(
                    nodes: [
                        GetHCoursesProgressionResponse.NodeModel(
                            courseProgression: GetHCoursesProgressionResponse.CourseProgression(
                                requirements: GetHCoursesProgressionResponse.Requirements(completionPercentage: 50.0),
                                incompleteModulesConnection: GetHCoursesProgressionResponse.IncompleteModulesConnection(
                                    nodes: [
                                        GetHCoursesProgressionResponse.IncompleteNode(
                                            module: GetHCoursesProgressionResponse.Module(
                                                id: "module_2",
                                                name: "Module 2",
                                                position: 2
                                            ),
                                            incompleteItemsConnection: GetHCoursesProgressionResponse.IncompleteItemsConnection(
                                                nodes: [
                                                    GetHCoursesProgressionResponse.ModuleContent(
                                                        url: "https://example.com/item2",
                                                        id: "item_2",
                                                        estimatedDuration: "45m",
                                                        content: GetHCoursesProgressionResponse.ContentNode(
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
        let mockEnrollment = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enrollment_4",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course_4",
                name: "Not Started Course",
                account: GetHCoursesProgressionResponse.AccountModel(name: "Not Started Account"),
                imageUrl: "https://example.com/notstarted.png",
                syllabusBody: "Not started syllabus",
                usersConnection: GetHCoursesProgressionResponse.UsersConnection(
                    nodes: [
                        GetHCoursesProgressionResponse.NodeModel(
                            courseProgression: GetHCoursesProgressionResponse.CourseProgression(
                                requirements: GetHCoursesProgressionResponse.Requirements(completionPercentage: 0.0),
                                incompleteModulesConnection: GetHCoursesProgressionResponse.IncompleteModulesConnection(nodes: [])
                            )
                        )
                    ]
                ),
                modulesConnection: GetHCoursesProgressionResponse.ModulesConnection(
                    edges: [
                        GetHCoursesProgressionResponse.ModulesConnection.Edge(
                            node: GetHCoursesProgressionResponse.ModulesConnection.Node(
                                id: "module_3",
                                name: "Module 3",
                                moduleItems: [
                                    GetHCoursesProgressionResponse.ModulesConnection.ModuleItem(
                                        id: "item_3",
                                        estimatedDuration: "60m",
                                        url: "https://example.com/item3",
                                        content: GetHCoursesProgressionResponse.ModulesConnection.Content(
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
