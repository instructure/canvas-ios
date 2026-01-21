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

import Combine
import CombineSchedulers
@testable import Core
@testable import Horizon
import XCTest

final class CourseListWidgetInteractorTests: HorizonTestCase {
    private var testee: CourseListWidgetInteractorLive!

    override func setUp() {
        super.setUp()
        testee = CourseListWidgetInteractorLive(
            userId: "test-user-123",
            scheduler: .immediate
        )
    }

    func testGetCoursesIgnoresCacheWhenRequested() async {
        // Given
        mockCoursesAPIResponse()

        // When
        let courses = try? await testee.getAndObserveCoursesWithoutModules(ignoreCache: true).asyncValue()

        // Then
        XCTAssertEqual(courses?.count, 2)
        XCTAssertTrue(courses?.contains(where: { $0.id == "course-1" }) ?? false)
        XCTAssertTrue(courses?.contains(where: { $0.id == "course-2" }) ?? false)
    }

    func testGetCoursesSorting() async {
        // Given
        mockCoursesAPIResponseWithProgress()

        // When
        let courses = try? await testee.getAndObserveCoursesWithoutModules(ignoreCache: true).asyncValue()

        // Then
        XCTAssertEqual(courses?.count, 4)
        XCTAssertNotNil(courses?[0].currentLearningObject)
        XCTAssertEqual(courses?[0].progress, 0.75)
        XCTAssertNotNil(courses?[1].currentLearningObject)
        XCTAssertEqual(courses?[1].progress, 0.5)
        XCTAssertNotNil(courses?[2].currentLearningObject)
        XCTAssertEqual(courses?[2].progress, 0.25)
        XCTAssertNil(courses?[3].currentLearningObject)
        XCTAssertEqual(courses?[3].progress, 1.0)
    }

    func testGetCoursesRefresh() async {
        // Given
        mockCoursesAPIResponse()
        let initialCourses = try? await testee.getAndObserveCoursesWithoutModules(ignoreCache: false).asyncValue()
        XCTAssertEqual(initialCourses?.count, 2)

        // When
        mockCoursesAPIResponseUpdated()
        let updatedCourses = try? await testee.getAndObserveCoursesWithoutModules(ignoreCache: true).asyncValue()

        // Then
        XCTAssertEqual(updatedCourses?.count, 3)
    }

    func testRefreshModuleItemsUponCompletions() async {
        // Given
        mockModuleItemAndModuleAPIResponse()
        let expectation = expectation(description: "Module item and module should be fetched")
        var fetchCallCount = 0

        let subscription = testee.refreshModuleItemsUponCompletions()
            .sink { _ in
                fetchCallCount += 1
                if fetchCallCount == 1 {
                    expectation.fulfill()
                }
            }

        // When
        let attributes = ModuleItemAttributes(
            courseID: "course-1",
            moduleID: "module-1",
            itemID: "item-1"
        )
        NotificationCenter.default.post(
            name: .moduleItemRequirementCompleted,
            object: attributes
        )

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(fetchCallCount, 1)

        let moduleItems: [ModuleItem] = databaseClient.fetch()
        XCTAssertFalse(moduleItems.isEmpty)

        let modules: [Module] = databaseClient.fetch()
        XCTAssertFalse(modules.isEmpty)

        subscription.cancel()
    }

    func testRefreshModuleItemsUponCompletionsHandlesError() async {
        // Given
        mockModuleItemAndModuleAPIResponseWithError()
        let expectation = expectation(description: "Error should be handled gracefully")
        var completionCallCount = 0

        let subscription = testee.refreshModuleItemsUponCompletions()
            .sink { _ in
                completionCallCount += 1
                if completionCallCount == 1 {
                    expectation.fulfill()
                }
            }

        // When
        let attributes = ModuleItemAttributes(
            courseID: "course-1",
            moduleID: "module-1",
            itemID: "item-1"
        )
        NotificationCenter.default.post(
            name: .moduleItemRequirementCompleted,
            object: attributes
        )

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(completionCallCount, 1)

        subscription.cancel()
    }

    func testRefreshModuleItemsUponCompletionsIgnoresNotificationsWithoutAttributes() async {
        // Given
        mockModuleItemAndModuleAPIResponse()
        let expectation = expectation(description: "Should not trigger fetch without attributes")
        expectation.isInverted = true
        var fetchCallCount = 0

        let subscription = testee.refreshModuleItemsUponCompletions()
            .sink { _ in
                fetchCallCount += 1
                expectation.fulfill()
            }

        // When
        NotificationCenter.default.post(
            name: .moduleItemRequirementCompleted,
            object: nil
        )

        // Then
        await fulfillment(of: [expectation], timeout: 0.5)
        XCTAssertEqual(fetchCallCount, 0)

        subscription.cancel()
    }

    // MARK: - Helper Methods

    private func mockCoursesAPIResponse() {
        let enrollment1 = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll-1",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course-1",
                name: "iOS Development 101",
                account: nil,
                imageUrl: nil,
                syllabusBody: nil,
                usersConnection: nil,
                modulesConnection: nil
            )
        )

        let enrollment2 = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll-2",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course-2",
                name: "Swift Programming",
                account: nil,
                imageUrl: nil,
                syllabusBody: nil,
                usersConnection: nil,
                modulesConnection: nil
            )
        )

        let response = GetHCoursesProgressionResponse(
            data: GetHCoursesProgressionResponse.DataModel(
                user: GetHCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: [enrollment1, enrollment2]
                )
            )
        )

        api.mock(GetHCoursesProgressionRequest(userId: "test-user-123", horizonCourses: true), value: response)
    }

    private func mockCoursesAPIResponseUpdated() {
        let enrollment1 = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll-1",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course-1",
                name: "iOS Development 101",
                account: nil,
                imageUrl: nil,
                syllabusBody: nil,
                usersConnection: nil,
                modulesConnection: nil
            )
        )

        let enrollment2 = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll-2",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course-2",
                name: "Swift Programming",
                account: nil,
                imageUrl: nil,
                syllabusBody: nil,
                usersConnection: nil,
                modulesConnection: nil
            )
        )

        let enrollment3 = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll-3",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course-3",
                name: "Advanced Swift",
                account: nil,
                imageUrl: nil,
                syllabusBody: nil,
                usersConnection: nil,
                modulesConnection: nil
            )
        )

        let response = GetHCoursesProgressionResponse(
            data: GetHCoursesProgressionResponse.DataModel(
                user: GetHCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: [enrollment1, enrollment2, enrollment3]
                )
            )
        )

        api.mock(GetHCoursesProgressionRequest(userId: "test-user-123", horizonCourses: true), value: response)
    }

    private func mockCoursesAPIResponseWithProgress() {
        let createCourse: (String, String, Double, Bool) -> GetHCoursesProgressionResponse.CourseModel = { id, name, progress, hasLearningObject in
            let userNode = GetHCoursesProgressionResponse.NodeModel(
                courseProgression: GetHCoursesProgressionResponse.CourseProgression(
                    requirements: GetHCoursesProgressionResponse.Requirements(
                        completionPercentage: progress
                    ),
                    incompleteModulesConnection: hasLearningObject ? GetHCoursesProgressionResponse.IncompleteModulesConnection(
                        nodes: [
                            GetHCoursesProgressionResponse.IncompleteNode(
                                module: GetHCoursesProgressionResponse.Module(id: "module-1", name: "Current Module", position: 1),
                                incompleteItemsConnection: GetHCoursesProgressionResponse.IncompleteItemsConnection(
                                    nodes: [
                                        GetHCoursesProgressionResponse.ModuleContent(
                                            url: "https://example.com/item",
                                            id: "item-1",
                                            estimatedDuration: "30 mins",
                                            content: GetHCoursesProgressionResponse.ContentNode(
                                                id: "content-1",
                                                title: "Next Item",
                                                dueAt: nil,
                                                position: 1,
                                                __typename: "Assignment",
                                                isNewQuiz: false
                                            )
                                        )
                                    ]
                                )
                            )
                        ]
                    ) : nil
                )
            )

            return GetHCoursesProgressionResponse.CourseModel(
                id: id,
                name: name,
                account: nil,
                imageUrl: nil,
                syllabusBody: nil,
                usersConnection: GetHCoursesProgressionResponse.UsersConnection(
                    nodes: [userNode]
                ),
                modulesConnection: nil
            )
        }

        let course1 = createCourse("course-1", "Course with 75% progress", 0.75, true)
        let course2 = createCourse("course-2", "Course with 50% progress", 0.5, true)
        let course3 = createCourse("course-3", "Course with 25% progress", 0.25, true)
        let course4 = createCourse("course-4", "Completed Course", 1.0, false)

        let enrollments = [
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-1", course: course1),
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-2", course: course2),
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-3", course: course3),
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-4", course: course4)
        ]

        let response = GetHCoursesProgressionResponse(
            data: GetHCoursesProgressionResponse.DataModel(
                user: GetHCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: enrollments
                )
            )
        )

        api.mock(GetHCoursesProgressionRequest(userId: "test-user-123", horizonCourses: true), value: response)
    }

    private func mockCoursesWithMixedProgress() {
        let createCourse: (String, String, Double, Bool) -> GetHCoursesProgressionResponse.CourseModel = { id, name, progress, hasLearningObject in
            let userNode = GetHCoursesProgressionResponse.NodeModel(
                courseProgression: GetHCoursesProgressionResponse.CourseProgression(
                    requirements: GetHCoursesProgressionResponse.Requirements(
                        completionPercentage: progress
                    ),
                    incompleteModulesConnection: hasLearningObject ? GetHCoursesProgressionResponse.IncompleteModulesConnection(
                        nodes: [
                            GetHCoursesProgressionResponse.IncompleteNode(
                                module: GetHCoursesProgressionResponse.Module(id: "module-1", name: "Current Module", position: 1),
                                incompleteItemsConnection: GetHCoursesProgressionResponse.IncompleteItemsConnection(
                                    nodes: [
                                        GetHCoursesProgressionResponse.ModuleContent(
                                            url: "https://example.com/item",
                                            id: "item-1",
                                            estimatedDuration: "30 mins",
                                            content: GetHCoursesProgressionResponse.ContentNode(
                                                id: "content-1",
                                                title: "Next Item",
                                                dueAt: nil,
                                                position: 1,
                                                __typename: "Assignment",
                                                isNewQuiz: false
                                            )
                                        )
                                    ]
                                )
                            )
                        ]
                    ) : nil
                )
            )

            return GetHCoursesProgressionResponse.CourseModel(
                id: id,
                name: name,
                account: nil,
                imageUrl: nil,
                syllabusBody: nil,
                usersConnection: GetHCoursesProgressionResponse.UsersConnection(
                    nodes: [userNode]
                ),
                modulesConnection: nil
            )
        }

        let courseHigh = createCourse("course-high", "High Progress In Progress", 0.9, true)
        let courseMedium = createCourse("course-medium", "Medium Progress In Progress", 0.6, true)
        let courseLow = createCourse("course-low", "Low Progress In Progress", 0.3, true)
        let courseCompletedHigh = createCourse("course-completed-high", "Completed High Progress", 1.0, false)
        let courseCompletedLow = createCourse("course-completed-low", "Completed Low Progress", 0.8, false)

        let enrollments = [
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-1", course: courseLow),
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-2", course: courseCompletedHigh),
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-3", course: courseMedium),
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-4", course: courseCompletedLow),
            GetHCoursesProgressionResponse.EnrollmentModel(state: "active", id: "enroll-5", course: courseHigh)
        ]

        let response = GetHCoursesProgressionResponse(
            data: GetHCoursesProgressionResponse.DataModel(
                user: GetHCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: enrollments
                )
            )
        )

        api.mock(GetHCoursesProgressionRequest(userId: "test-user-123", horizonCourses: true), value: response)
    }

    private func mockEmptyCoursesAPIResponse() {
        let response = GetHCoursesProgressionResponse(
            data: GetHCoursesProgressionResponse.DataModel(
                user: GetHCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: []
                )
            )
        )

        api.mock(GetHCoursesProgressionRequest(userId: "test-user-123", horizonCourses: true), value: response)
    }

    private func mockCoursesAPIResponseWithIncompleteModuleItem() {
        let userNode = GetHCoursesProgressionResponse.NodeModel(
            courseProgression: GetHCoursesProgressionResponse.CourseProgression(
                requirements: GetHCoursesProgressionResponse.Requirements(
                    completionPercentage: 0.5
                ),
                incompleteModulesConnection: GetHCoursesProgressionResponse.IncompleteModulesConnection(
                    nodes: [
                        GetHCoursesProgressionResponse.IncompleteNode(
                            module: GetHCoursesProgressionResponse.Module(id: "module-1", name: "Test Module", position: 1),
                            incompleteItemsConnection: GetHCoursesProgressionResponse.IncompleteItemsConnection(
                                nodes: [
                                    GetHCoursesProgressionResponse.ModuleContent(
                                        url: "https://example.com/item-1",
                                        id: "item-1",
                                        estimatedDuration: "30 mins",
                                        content: GetHCoursesProgressionResponse.ContentNode(
                                            id: "content-1",
                                            title: "Incomplete Module Item",
                                            dueAt: nil,
                                            position: 1,
                                            __typename: "Assignment",
                                            isNewQuiz: false
                                        )
                                    )
                                ]
                            )
                        )
                    ]
                )
            )
        )

        let course = GetHCoursesProgressionResponse.CourseModel(
            id: "course-1",
            name: "Test Course",
            account: nil,
            imageUrl: nil,
            syllabusBody: nil,
            usersConnection: GetHCoursesProgressionResponse.UsersConnection(
                nodes: [userNode]
            ),
            modulesConnection: nil
        )

        let enrollment = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll-1",
            course: course
        )

        let response = GetHCoursesProgressionResponse(
            data: GetHCoursesProgressionResponse.DataModel(
                user: GetHCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: [enrollment]
                )
            )
        )

        api.mock(GetHCoursesProgressionRequest(userId: "test-user-123", horizonCourses: true), value: response)
    }

    private func mockCoursesAPIResponseWithCompletedModuleItem() {
        let userNode = GetHCoursesProgressionResponse.NodeModel(
            courseProgression: GetHCoursesProgressionResponse.CourseProgression(
                requirements: GetHCoursesProgressionResponse.Requirements(
                    completionPercentage: 1.0
                ),
                incompleteModulesConnection: nil // No incomplete items means course is completed
            )
        )

        let course = GetHCoursesProgressionResponse.CourseModel(
            id: "course-1",
            name: "Test Course",
            account: nil,
            imageUrl: nil,
            syllabusBody: nil,
            usersConnection: GetHCoursesProgressionResponse.UsersConnection(
                nodes: [userNode]
            ),
            modulesConnection: nil
        )

        let enrollment = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll-1",
            course: course
        )

        let response = GetHCoursesProgressionResponse(
            data: GetHCoursesProgressionResponse.DataModel(
                user: GetHCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: [enrollment]
                )
            )
        )

        api.mock(GetHCoursesProgressionRequest(userId: "test-user-123", horizonCourses: true), value: response)
    }

    private func mockModuleItemAndModuleAPIResponse() {
        api.mock(
            GetModuleItemRequest(
                courseID: "course-1",
                moduleID: "module-1",
                itemID: "item-1",
                include: [.content_details]
            ),
            value: .make()
        )

        api.mock(
            GetModuleRequest(courseID: "course-1", moduleID: "module-1", include: []),
            value: .make()
        )
    }

    private func mockModuleItemAndModuleAPIResponseWithError() {
        api.mock(
            GetModuleItemRequest(
                courseID: "course-1",
                moduleID: "module-1",
                itemID: "item-1",
                include: [.content_details]
            ),
            error: NSError.instructureError("Test error")
        )

        api.mock(
            GetModuleRequest(courseID: "course-1", moduleID: "module-1", include: []),
            error: NSError.instructureError("Test error")
        )
    }
}
