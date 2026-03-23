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
import Combine
import TestsFoundation

final class LearnItemInteractorTests: HorizonTestCase {

    // MARK: - Get Items Tests

    func testGetItemsReturnsActiveItems() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockLearnItemsResponse(itemCount: 3, status: [.completed])

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: [.inProgress]
            )
        ) { items in
            XCTAssertEqual(items.count, 3)
        }
    }

    func testGetItemsWithSearchTerm() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockLearnItemsWithSearchResponse(searchTerm: "Swift")

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: "Swift",
                itemTypes: nil,
                sortBy: nil,
                status: [.notStarted]
            )
        ) { items in
            XCTAssertGreaterThan(items.count, 0)
            XCTAssertTrue(items.contains { $0.name.contains("Swift") })
        }
    }

    func testGetItemsWithItemTypesFilter() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockLearnItemsWithTypeFilter(types: ["COURSE"])

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: nil,
                itemTypes: ["COURSE"],
                sortBy: nil,
                status: [.inProgress]
            )
        ) { items in
            XCTAssertGreaterThan(items.count, 0)
            XCTAssertTrue(items.allSatisfy { $0.itemType == .course })
        }
    }

    func testGetItemsWithSortBy() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockLearnItemsWithSort(sortBy: "NAME_ASC")

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: "NAME_ASC",
                status: [.completed]
            )
        ) { items in
            XCTAssertGreaterThan(items.count, 1)
            let sortedNames = items.map { $0.name }
            XCTAssertEqual(sortedNames, sortedNames.sorted())
        }
    }

    func testGetItemsWithMultipleStatuses() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockLearnItemsResponse(itemCount: 5, status: [.notStarted, .inProgress])

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: [.notStarted, .inProgress]
            )
        ) { items in
            XCTAssertEqual(items.count, 5)
        }
    }

    func testGetItemsReturnsEmptyWhenNoItems() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockEmptyLearnItemsResponse()

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: [.inProgress]
            )
        ) { items in
            XCTAssertEqual(items.count, 0)
        }
    }

    func testGetItemsSortsItemsByPosition() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockLearnItemsWithPositions()

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: [.completed]
            )
        ) { items in
            XCTAssertGreaterThan(items.count, 1)
            for i in 0..<items.count - 1 {
                XCTAssertLessThanOrEqual(items[i].position, items[i + 1].position)
            }
        }
    }

    func testGetItemsWithAllFilters() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockLearnItemsWithAllFilters(searchTerm: "Development", types: ["COURSE"], sortBy: "NAME_ASC", status: [.inProgress])

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: "Development",
                itemTypes: ["COURSE"],
                sortBy: "NAME_ASC",
                status: [.inProgress]
            )
        ) { items in
            XCTAssertGreaterThan(items.count, 0)
        }
    }

    func testGetItemsIncludesCourseWithIncompleteModules() {
        let testee = LearnItemInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockLearnItemsWithIncompleteModules()

        XCTAssertSingleOutputAndFinish(
            testee.getItems(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: [.inProgress]
            )
        ) { items in
            let courseWithModules = items.first { $0.nextModuleItemID != nil }
            XCTAssertNotNil(courseWithModules)
        }
    }

    // MARK: - Helper Methods

    private func mockJWTToken() {
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token")
        )
    }

    private func mockLearnItemsResponse(itemCount: Int, status: [LearnItemModel.Status]) {
        var items: [GetLearnItemsResponse.Item] = []

        for i in 1...itemCount {
            items.append(GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-\(i)",
                name: "Course \(i)",
                itemType: "COURSE",
                position: i,
                enrollmentId: "enrollment-\(i)",
                startAt: nil,
                endAt: nil,
                enrolledAt: "2026-01-01T00:00:00Z",
                completionPercentage: Double(i * 20),
                requirementCount: 10,
                requirementCompletedCount: i * 2,
                completedAt: nil,
                grade: nil,
                imageURL: nil,
                workflowState: "active",
                lastActivityAt: nil,
                estimatedDurationMinutes: 120,
                courseCount: nil,
                incompleteModules: nil
            ))
        }

        api.mock(
            GetLearnItemsRequest(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: status.map { $0.rawValue }
            ),
            value: GetLearnItemsResponse(
                data: .init(
                    learnItems: .init(
                        items: items,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockEmptyLearnItemsResponse() {
        api.mock(
            GetLearnItemsRequest(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: [LearnItemModel.Status.inProgress.rawValue]
            ),
            value: GetLearnItemsResponse(
                data: .init(
                    learnItems: .init(
                        items: [],
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockLearnItemsWithSearchResponse(searchTerm: String) {
        let items = [
            GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-1",
                name: "Swift Programming",
                itemType: "COURSE",
                position: 1,
                enrollmentId: "enrollment-1",
                startAt: nil,
                endAt: nil,
                enrolledAt: "2026-01-01T00:00:00Z",
                completionPercentage: 50.0,
                requirementCount: 10,
                requirementCompletedCount: 5,
                completedAt: nil,
                grade: nil,
                imageURL: nil,
                workflowState: "active",
                lastActivityAt: nil,
                estimatedDurationMinutes: 180,
                courseCount: nil,
                incompleteModules: nil
            )
        ]

        api.mock(
            GetLearnItemsRequest(
                searchTerm: searchTerm,
                itemTypes: nil,
                sortBy: nil,
                status: [LearnItemModel.Status.inProgress.rawValue]
            ),
            value: GetLearnItemsResponse(
                data: .init(
                    learnItems: .init(
                        items: items,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockLearnItemsWithTypeFilter(types: [String]) {
        let items = [
            GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-1",
                name: "iOS Development",
                itemType: "COURSE",
                position: 1,
                enrollmentId: "enrollment-1",
                startAt: nil,
                endAt: nil,
                enrolledAt: "2026-01-01T00:00:00Z",
                completionPercentage: 30.0,
                requirementCount: 15,
                requirementCompletedCount: 5,
                completedAt: nil,
                grade: nil,
                imageURL: nil,
                workflowState: "active",
                lastActivityAt: nil,
                estimatedDurationMinutes: 240,
                courseCount: nil,
                incompleteModules: nil
            )
        ]

        api.mock(
            GetLearnItemsRequest(
                searchTerm: nil,
                itemTypes: types,
                sortBy: nil,
                status: [LearnItemModel.Status.inProgress.rawValue]
            ),
            value: GetLearnItemsResponse(
                data: .init(
                    learnItems: .init(
                        items: items,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockLearnItemsWithSort(sortBy: String) {
        let items = [
            GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-1",
                name: "A Course",
                itemType: "COURSE",
                position: 1,
                enrollmentId: "enrollment-1",
                startAt: nil,
                endAt: nil,
                enrolledAt: "2026-01-01T00:00:00Z",
                completionPercentage: 40.0,
                requirementCount: 10,
                requirementCompletedCount: 4,
                completedAt: nil,
                grade: nil,
                imageURL: nil,
                workflowState: "active",
                lastActivityAt: nil,
                estimatedDurationMinutes: 120,
                courseCount: nil,
                incompleteModules: nil
            ),
            GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-2",
                name: "B Course",
                itemType: "COURSE",
                position: 2,
                enrollmentId: "enrollment-2",
                startAt: nil,
                endAt: nil,
                enrolledAt: "2026-01-01T00:00:00Z",
                completionPercentage: 60.0,
                requirementCount: 10,
                requirementCompletedCount: 6,
                completedAt: nil,
                grade: nil,
                imageURL: nil,
                workflowState: "active",
                lastActivityAt: nil,
                estimatedDurationMinutes: 150,
                courseCount: nil,
                incompleteModules: nil
            )
        ]

        api.mock(
            GetLearnItemsRequest(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: sortBy,
                status: [LearnItemModel.Status.inProgress.rawValue]
            ),
            value: GetLearnItemsResponse(
                data: .init(
                    learnItems: .init(
                        items: items,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockLearnItemsWithPositions() {
        let items = [
            GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-1",
                name: "Course 1",
                itemType: "COURSE",
                position: 1,
                enrollmentId: "enrollment-1",
                startAt: nil,
                endAt: nil,
                enrolledAt: "2026-01-01T00:00:00Z",
                completionPercentage: 25.0,
                requirementCount: 10,
                requirementCompletedCount: 2,
                completedAt: nil,
                grade: nil,
                imageURL: nil,
                workflowState: "active",
                lastActivityAt: nil,
                estimatedDurationMinutes: 100,
                courseCount: nil,
                incompleteModules: nil
            ),
            GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-2",
                name: "Course 2",
                itemType: "COURSE",
                position: 2,
                enrollmentId: "enrollment-2",
                startAt: nil,
                endAt: nil,
                enrolledAt: "2026-01-01T00:00:00Z",
                completionPercentage: 75.0,
                requirementCount: 10,
                requirementCompletedCount: 7,
                completedAt: nil,
                grade: nil,
                imageURL: nil,
                workflowState: "active",
                lastActivityAt: nil,
                estimatedDurationMinutes: 200,
                courseCount: nil,
                incompleteModules: nil
            )
        ]

        api.mock(
            GetLearnItemsRequest(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: [LearnItemModel.Status.inProgress.rawValue]
            ),
            value: GetLearnItemsResponse(
                data: .init(
                    learnItems: .init(
                        items: items,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockLearnItemsWithAllFilters(searchTerm: String, types: [String], sortBy: String, status: [LearnItemModel.Status]) {
        let items = [
            GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-1",
                name: "Mobile Development",
                itemType: "COURSE",
                position: 1,
                enrollmentId: "enrollment-1",
                startAt: nil,
                endAt: nil,
                enrolledAt: "2026-01-01T00:00:00Z",
                completionPercentage: 55.0,
                requirementCount: 12,
                requirementCompletedCount: 6,
                completedAt: nil,
                grade: nil,
                imageURL: nil,
                workflowState: "active",
                lastActivityAt: nil,
                estimatedDurationMinutes: 300,
                courseCount: nil,
                incompleteModules: nil
            )
        ]

        api.mock(
            GetLearnItemsRequest(
                searchTerm: searchTerm,
                itemTypes: types,
                sortBy: sortBy,
                status: status.map { $0.rawValue }
            ),
            value: GetLearnItemsResponse(
                data: .init(
                    learnItems: .init(
                        items: items,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockLearnItemsWithIncompleteModules() {
        let items = [
            GetLearnItemsResponse.Item(
                typename: "CourseEnrollmentItemGQL",
                id: "item-1",
                name: "Course with Modules",
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
                            GetLearnItemsResponse.IncompleteItem(id: "module-item-1")
                        ]
                    )
                ]
            )
        ]

        api.mock(
            GetLearnItemsRequest(
                searchTerm: nil,
                itemTypes: nil,
                sortBy: nil,
                status: [LearnItemModel.Status.inProgress.rawValue]
            ),
            value: GetLearnItemsResponse(
                data: .init(
                    learnItems: .init(
                        items: items,
                        pageInfo: nil
                    )
                )
            )
        )
    }
}
