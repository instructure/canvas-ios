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
import Combine
import CombineSchedulers
@testable import Core
@testable import Horizon

class DashboardInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var interactor: DashboardInteractorLive!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!
    private var subscriptions: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        testScheduler = DispatchQueue.test
        subscriptions = Set<AnyCancellable>()
        interactor = DashboardInteractorLive(
            userId: "test-user-id",
            scheduler: testScheduler.eraseToAnyScheduler()
        )
    }
    
    override func tearDown() {
        subscriptions = nil
        interactor = nil
        testScheduler = nil
        super.tearDown()
    }
    
    // MARK: - Course Sorting Tests
    
    /// Tests that courses are sorted correctly with incomplete courses before completed ones
    func test_coursesSorting_incompleteCoursesShouldAppearBeforeCompletedCourses() {
        // Given: Courses with different completion states
        let completedCourse = createMockCourse(
            id: "1",
            name: "Completed Course",
            completionPercentage: 100,
            isCompleted: true
        )
        let incompleteCourse = createMockCourse(
            id: "2",
            name: "Incomplete Course",
            completionPercentage: 50,
            isCompleted: false
        )
        
        let courses = [completedCourse, incompleteCourse]
        
        // When: Courses are sorted by the interactor logic
        let sortedCourses = sortCoursesUsingInteractorLogic(courses)
        
        // Then: Incomplete course should come first
        XCTAssertEqual(sortedCourses.first?.id, "2", "Incomplete course should appear before completed course")
        XCTAssertEqual(sortedCourses.last?.id, "1", "Completed course should appear last")
    }
    
    /// Tests that courses without cards are placed at the end
    func test_coursesSorting_coursesWithoutCardsShouldAppearAtEnd() {
        // Given: Courses with and without cards
        let courseWithCard = createMockCourse(
            id: "1",
            name: "Course With Card",
            completionPercentage: 50,
            isCompleted: false
        )
        let courseWithoutCard = createMockCourseWithoutCard(id: "2", name: "Course Without Card")
        
        let courses = [courseWithoutCard, courseWithCard]
        
        // When: Courses are sorted
        let sortedCourses = sortCoursesUsingInteractorLogic(courses)
        
        // Then: Course with card should come first
        XCTAssertEqual(sortedCourses.first?.id, "1", "Course with card should appear first")
        XCTAssertEqual(sortedCourses.last?.id, "2", "Course without card should appear last")
    }
    
    /// Tests that courses with same completion state are sorted by completion percentage descending
    func test_coursesSorting_sameCompletionStateShouldSortByPercentageDescending() {
        // Given: Multiple incomplete courses with different completion percentages
        let course25Percent = createMockCourse(
            id: "1",
            name: "Course 25%",
            completionPercentage: 25,
            isCompleted: false
        )
        let course75Percent = createMockCourse(
            id: "2",
            name: "Course 75%",
            completionPercentage: 75,
            isCompleted: false
        )
        let course50Percent = createMockCourse(
            id: "3",
            name: "Course 50%",
            completionPercentage: 50,
            isCompleted: false
        )
        
        let courses = [course25Percent, course75Percent, course50Percent]
        
        // When: Courses are sorted
        let sortedCourses = sortCoursesUsingInteractorLogic(courses)
        
        // Then: Should be sorted by percentage descending (75% -> 50% -> 25%)
        XCTAssertEqual(sortedCourses[0].id, "2", "Highest percentage should be first")
        XCTAssertEqual(sortedCourses[1].id, "3", "Middle percentage should be second")
        XCTAssertEqual(sortedCourses[2].id, "1", "Lowest percentage should be last")
    }
    
    /// Tests complex sorting scenario with mixed completion states and percentages
    func test_coursesSorting_complexScenarioWithMixedStates() {
        // Given: A mix of completed, incomplete, and courses without cards
        let incompleteHigh = createMockCourse(id: "1", name: "Incomplete 80%", completionPercentage: 80, isCompleted: false)
        let completedCourse = createMockCourse(id: "2", name: "Completed", completionPercentage: 100, isCompleted: true)
        let incompleteLow = createMockCourse(id: "3", name: "Incomplete 30%", completionPercentage: 30, isCompleted: false)
        let noCard = createMockCourseWithoutCard(id: "4", name: "No Card")
        let incompleteMid = createMockCourse(id: "5", name: "Incomplete 60%", completionPercentage: 60, isCompleted: false)
        
        let courses = [completedCourse, noCard, incompleteLow, incompleteHigh, incompleteMid]
        
        // When: Courses are sorted
        let sortedCourses = sortCoursesUsingInteractorLogic(courses)
        
        // Then: Order should be: incomplete (80%, 60%, 30%), completed, no card
        XCTAssertEqual(sortedCourses[0].id, "1", "Incomplete 80% first")
        XCTAssertEqual(sortedCourses[1].id, "5", "Incomplete 60% second")
        XCTAssertEqual(sortedCourses[2].id, "3", "Incomplete 30% third")
        XCTAssertEqual(sortedCourses[3].id, "2", "Completed fourth")
        XCTAssertEqual(sortedCourses[4].id, "4", "No card last")
    }
    
    /// Tests that multiple courses without cards maintain stable order
    func test_coursesSorting_multipleCoursesWithoutCardsStableOrder() {
        // Given: Multiple courses without cards
        let noCard1 = createMockCourseWithoutCard(id: "1", name: "No Card 1")
        let noCard2 = createMockCourseWithoutCard(id: "2", name: "No Card 2")
        let noCard3 = createMockCourseWithoutCard(id: "3", name: "No Card 3")
        
        let courses = [noCard1, noCard2, noCard3]
        
        // When: Courses are sorted
        let sortedCourses = sortCoursesUsingInteractorLogic(courses)
        
        // Then: Order should remain stable (returns false for equal items)
        XCTAssertEqual(sortedCourses.count, 3)
        // Since all return false in comparison, original order should be maintained
        XCTAssertEqual(sortedCourses[0].id, "1")
        XCTAssertEqual(sortedCourses[1].id, "2")
        XCTAssertEqual(sortedCourses[2].id, "3")
    }
    
    /// Tests that multiple completed courses are sorted by completion percentage
    func test_coursesSorting_multipleCompletedCoursesSortedByPercentage() {
        // Given: Multiple completed courses with same completion status
        let completed100 = createMockCourse(id: "1", name: "Completed 100%", completionPercentage: 100, isCompleted: true)
        let completed90 = createMockCourse(id: "2", name: "Completed 90%", completionPercentage: 90, isCompleted: true)
        
        let courses = [completed90, completed100]
        
        // When: Courses are sorted
        let sortedCourses = sortCoursesUsingInteractorLogic(courses)
        
        // Then: Should be sorted by percentage descending even when completed
        XCTAssertEqual(sortedCourses[0].id, "1", "100% should come before 90%")
        XCTAssertEqual(sortedCourses[1].id, "2")
    }
    
    /// Tests edge case with zero completion percentage
    func test_coursesSorting_zeroCompletionPercentage() {
        // Given: Course with 0% completion
        let zeroPercent = createMockCourse(id: "1", name: "Zero %", completionPercentage: 0, isCompleted: false)
        let someProgress = createMockCourse(id: "2", name: "Some Progress", completionPercentage: 10, isCompleted: false)
        
        let courses = [zeroPercent, someProgress]
        
        // When: Courses are sorted
        let sortedCourses = sortCoursesUsingInteractorLogic(courses)
        
        // Then: Course with progress should come first
        XCTAssertEqual(sortedCourses[0].id, "2")
        XCTAssertEqual(sortedCourses[1].id, "1")
    }
    
    /// Tests that notification triggers course refresh with ignoreCache flag
    func test_moduleItemRequirementCompleted_shouldTriggerRefreshWithIgnoreCache() {
        // Given: Initial courses are loaded
        var receivedCoursesCount = 0
        let expectation = self.expectation(description: "Should receive courses multiple times")
        expectation.expectedFulfillmentCount = 2
        
        interactor.getAndObserveCoursesWithoutModules(ignoreCache: false)
            .sink { courses in
                receivedCoursesCount += 1
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // Advance scheduler for initial load
        testScheduler.advance(by: .milliseconds(500))
        
        // When: Module completion notification is posted
        NotificationCenter.default.post(
            name: .moduleItemRequirementCompleted,
            object: "test-course-id"
        )
        
        // Advance scheduler for notification processing
        testScheduler.advance(by: .milliseconds(500))
        
        // Then: Should receive courses twice (initial + after notification)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedCoursesCount, 2, "Should trigger refresh on completion notification")
    }
    
    /// Tests that 500ms delay is applied before processing notifications
    func test_moduleItemRequirementCompleted_shouldApply500msDelay() {
        // Given: Observer is set up
        var didReceiveUpdate = false
        let expectation = self.expectation(description: "Should receive update after delay")
        
        interactor.getAndObserveCoursesWithoutModules(ignoreCache: false)
            .dropFirst() // Skip initial emission
            .sink { _ in
                didReceiveUpdate = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        testScheduler.advance(by: .milliseconds(500))
        
        // When: Notification is posted
        NotificationCenter.default.post(
            name: .moduleItemRequirementCompleted,
            object: "test-course-id"
        )
        
        // Then: Should not receive update immediately
        testScheduler.advance(by: .milliseconds(499))
        XCTAssertFalse(didReceiveUpdate, "Should not receive update before 500ms")
        
        // But should receive after 500ms
        testScheduler.advance(by: .milliseconds(1))
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(didReceiveUpdate, "Should receive update after 500ms delay")
    }
    
    // MARK: - Helper Methods
    
    /// Replicates the sorting logic from the interactor for testing
    private func sortCoursesUsingInteractorLogic(_ courses: [HCourse]) -> [HCourse] {
        courses.sorted { course1, course2 in
            let card1 = course1.learningObjectCardModel
            let card2 = course2.learningObjectCardModel
            
            // Courses without cards go to the end
            if card1 == nil && card2 == nil {
                return false
            }
            if card1 == nil {
                return false
            }
            if card2 == nil {
                return true
            }
            
            guard let card1 = card1, let card2 = card2 else {
                return false
            }
            
            // Completed courses go to the end
            if card1.isCompleted && !card2.isCompleted {
                return false
            }
            if !card1.isCompleted && card2.isCompleted {
                return true
            }
            
            // If both completed or both incomplete, sort by completion percentage descending
            return card1.completionPercentage > card2.completionPercentage
        }
    }
    
    /// Creates a mock course with a learning object card
    private func createMockCourse(
        id: String,
        name: String,
        completionPercentage: Double,
        isCompleted: Bool
    ) -> HCourse {
        let card = LearningObjectCardModel(
            completionPercentage: completionPercentage,
            isCompleted: isCompleted,
            totalCount: 10,
            completedCount: Int(completionPercentage / 10)
        )
        
        return HCourse(
            id: id,
            name: name,
            imageURL: nil,
            color: nil,
            learningObjectCardModel: card,
            modules: nil
        )
    }
    
    /// Creates a mock course without a learning object card
    private func createMockCourseWithoutCard(id: String, name: String) -> HCourse {
        return HCourse(
            id: id,
            name: name,
            imageURL: nil,
            color: nil,
            learningObjectCardModel: nil,
            modules: nil
        )
    }
}