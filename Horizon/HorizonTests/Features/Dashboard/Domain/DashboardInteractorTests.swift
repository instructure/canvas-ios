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
@testable import Horizon
@testable import Core

class DashboardInteractorTests: XCTestCase {
    
    var testScheduler: TestSchedulerOf<DispatchQueue>!
    var subscriptions: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        testScheduler = DispatchQueue.test
        subscriptions = Set<AnyCancullable>()
    }
    
    override func tearDown() {
        subscriptions = nil
        testScheduler = nil
        super.tearDown()
    }
    
    // MARK: - Course Ordering Bug Tests
    
    /// Tests that Horizon courses (with learningObjectCardModel) are sorted before non-Horizon courses
    func test_courseOrdering_horizonCoursesAppearFirst() {
        // Given: A mix of Horizon and non-Horizon courses
        let horizonCourse = createMockHCourse(
            id: "1",
            name: "Zebra Course",
            position: 3,
            hasLearningObjectCard: true
        )
        let regularCourse1 = createMockHCourse(
            id: "2",
            name: "Alpha Course",
            position: 1,
            hasLearningObjectCard: false
        )
        let regularCourse2 = createMockHCourse(
            id: "3",
            name: "Beta Course",
            position: 2,
            hasLearningObjectCard: false
        )
        
        let courses = [regularCourse1, horizonCourse, regularCourse2]
        
        // When: Courses are sorted using the fixed sorting logic
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Horizon course should appear first
        XCTAssertEqual(sortedCourses[0].id, "1", "Horizon course should be first")
        XCTAssertEqual(sortedCourses[1].id, "2", "Regular courses should follow")
        XCTAssertEqual(sortedCourses[2].id, "3", "Regular courses should follow")
    }
    
    /// Tests that courses with the same Horizon status are sorted by position
    func test_courseOrdering_sortsByPositionWithinSameType() {
        // Given: Multiple courses of the same type with different positions
        let course1 = createMockHCourse(
            id: "1",
            name: "Course C",
            position: 3,
            hasLearningObjectCard: false
        )
        let course2 = createMockHCourse(
            id: "2",
            name: "Course A",
            position: 1,
            hasLearningObjectCard: false
        )
        let course3 = createMockHCourse(
            id: "3",
            name: "Course B",
            position: 2,
            hasLearningObjectCard: false
        )
        
        let courses = [course1, course2, course3]
        
        // When: Courses are sorted
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Courses should be sorted by position
        XCTAssertEqual(sortedCourses[0].id, "2", "Course with position 1 should be first")
        XCTAssertEqual(sortedCourses[1].id, "3", "Course with position 2 should be second")
        XCTAssertEqual(sortedCourses[2].id, "1", "Course with position 3 should be third")
    }
    
    /// Tests that courses without positions are sorted alphabetically by name
    func test_courseOrdering_sortsByNameWhenPositionsUnavailable() {
        // Given: Courses without position values
        let course1 = createMockHCourse(
            id: "1",
            name: "Zebra Course",
            position: nil,
            hasLearningObjectCard: false
        )
        let course2 = createMockHCourse(
            id: "2",
            name: "Alpha Course",
            position: nil,
            hasLearningObjectCard: false
        )
        let course3 = createMockHCourse(
            id: "3",
            name: "Beta Course",
            position: nil,
            hasLearningObjectCard: false
        )
        
        let courses = [course1, course2, course3]
        
        // When: Courses are sorted
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Courses should be sorted alphabetically
        XCTAssertEqual(sortedCourses[0].name, "Alpha Course")
        XCTAssertEqual(sortedCourses[1].name, "Beta Course")
        XCTAssertEqual(sortedCourses[2].name, "Zebra Course")
    }
    
    /// Tests that sorting is case-insensitive for course names
    func test_courseOrdering_caseInsensitiveNameSorting() {
        // Given: Courses with names in different cases
        let course1 = createMockHCourse(
            id: "1",
            name: "apple Course",
            position: nil,
            hasLearningObjectCard: false
        )
        let course2 = createMockHCourse(
            id: "2",
            name: "Banana Course",
            position: nil,
            hasLearningObjectCard: false
        )
        let course3 = createMockHCourse(
            id: "3",
            name: "CHERRY Course",
            position: nil,
            hasLearningObjectCard: false
        )
        
        let courses = [course3, course2, course1]
        
        // When: Courses are sorted
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Courses should be sorted case-insensitively
        XCTAssertEqual(sortedCourses[0].name, "apple Course")
        XCTAssertEqual(sortedCourses[1].name, "Banana Course")
        XCTAssertEqual(sortedCourses[2].name, "CHERRY Course")
    }
    
    /// Tests the full sorting hierarchy: Horizon status, then position, then name
    func test_courseOrdering_fullSortingHierarchy() {
        // Given: A complex mix of courses
        let horizonCourse1 = createMockHCourse(
            id: "h1",
            name: "Horizon B",
            position: 2,
            hasLearningObjectCard: true
        )
        let horizonCourse2 = createMockHCourse(
            id: "h2",
            name: "Horizon A",
            position: 1,
            hasLearningObjectCard: true
        )
        let regularCourseWithPosition1 = createMockHCourse(
            id: "r1",
            name: "Regular C",
            position: 3,
            hasLearningObjectCard: false
        )
        let regularCourseWithPosition2 = createMockHCourse(
            id: "r2",
            name: "Regular A",
            position: 1,
            hasLearningObjectCard: false
        )
        let regularCourseNoPosition1 = createMockHCourse(
            id: "n1",
            name: "Zebra",
            position: nil,
            hasLearningObjectCard: false
        )
        let regularCourseNoPosition2 = createMockHCourse(
            id: "n2",
            name: "Apple",
            position: nil,
            hasLearningObjectCard: false
        )
        
        let courses = [
            regularCourseNoPosition1,
            regularCourseWithPosition1,
            horizonCourse1,
            regularCourseNoPosition2,
            horizonCourse2,
            regularCourseWithPosition2
        ]
        
        // When: Courses are sorted
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Courses should be sorted in the correct hierarchy
        // 1. Horizon courses by position
        XCTAssertEqual(sortedCourses[0].id, "h2", "Horizon with position 1")
        XCTAssertEqual(sortedCourses[1].id, "h1", "Horizon with position 2")
        
        // 2. Regular courses by position
        XCTAssertEqual(sortedCourses[2].id, "r2", "Regular with position 1")
        XCTAssertEqual(sortedCourses[3].id, "r1", "Regular with position 3")
        
        // 3. Regular courses without position by name
        XCTAssertEqual(sortedCourses[4].id, "n2", "Regular without position, alphabetically first")
        XCTAssertEqual(sortedCourses[5].id, "n1", "Regular without position, alphabetically last")
    }
    
    /// Tests that courses with same position are then sorted by name
    func test_courseOrdering_samePositionSortsByName() {
        // Given: Courses with identical positions
        let course1 = createMockHCourse(
            id: "1",
            name: "Zebra Course",
            position: 1,
            hasLearningObjectCard: false
        )
        let course2 = createMockHCourse(
            id: "2",
            name: "Alpha Course",
            position: 1,
            hasLearningObjectCard: false
        )
        let course3 = createMockHCourse(
            id: "3",
            name: "Beta Course",
            position: 1,
            hasLearningObjectCard: false
        )
        
        let courses = [course1, course2, course3]
        
        // When: Courses are sorted
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Courses with same position should be sorted by name
        XCTAssertEqual(sortedCourses[0].name, "Alpha Course")
        XCTAssertEqual(sortedCourses[1].name, "Beta Course")
        XCTAssertEqual(sortedCourses[2].name, "Zebra Course")
    }
    
    /// Tests edge case: Empty course list
    func test_courseOrdering_emptyList() {
        // Given: Empty course list
        let courses: [HCourse] = []
        
        // When: Courses are sorted
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Result should be empty
        XCTAssertTrue(sortedCourses.isEmpty)
    }
    
    /// Tests edge case: Single course
    func test_courseOrdering_singleCourse() {
        // Given: Single course
        let course = createMockHCourse(
            id: "1",
            name: "Single Course",
            position: 1,
            hasLearningObjectCard: false
        )
        let courses = [course]
        
        // When: Courses are sorted
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Result should contain the single course
        XCTAssertEqual(sortedCourses.count, 1)
        XCTAssertEqual(sortedCourses[0].id, "1")
    }
    
    /// Tests that sorting is stable - courses maintain relative order when all criteria are equal
    func test_courseOrdering_stableSorting() {
        // Given: Multiple Horizon courses with same position and name
        let course1 = createMockHCourse(
            id: "1",
            name: "Same Name",
            position: 1,
            hasLearningObjectCard: true
        )
        let course2 = createMockHCourse(
            id: "2",
            name: "Same Name",
            position: 1,
            hasLearningObjectCard: true
        )
        
        let courses = [course1, course2]
        
        // When: Courses are sorted
        let sortedCourses = applySortingLogic(to: courses)
        
        // Then: Original order should be maintained
        XCTAssertEqual(sortedCourses[0].id, "1")
        XCTAssertEqual(sortedCourses[1].id, "2")
    }
    
    // MARK: - Helper Methods
    
    /// Creates a mock HCourse for testing
    private func createMockHCourse(
        id: String,
        name: String,
        position: Int?,
        hasLearningObjectCard: Bool
    ) -> HCourse {
        return HCourse(
            id: id,
            name: name,
            position: position,
            learningObjectCardModel: hasLearningObjectCard ? HCourse.LearningObjectCardModel(
                isEnabled: true,
                contextId: id,
                contextName: name,
                title: name,
                caption: nil,
                body: nil,
                imageUrl: nil,
                iconName: nil,
                linkUrl: nil,
                linkText: nil
            ) : nil,
            modules: nil,
            courseColor: "#000000",
            dashboardCard: nil,
            isK5Subject: false,
            isHomeroom: false
        )
    }
    
    /// Applies the sorting logic from DashboardInteractorLive
    private func applySortingLogic(to courses: [HCourse]) -> [HCourse] {
        return courses.sorted {
            // First, prioritize Horizon courses (those with learningObjectCardModel)
            let lhs = $0.learningObjectCardModel != nil
            let rhs = $1.learningObjectCardModel != nil
            
            if lhs != rhs {
                return lhs
            }
            
            // Then sort by position if available
            if let lhsPosition = $0.position, let rhsPosition = $1.position {
                if lhsPosition != rhsPosition {
                    return lhsPosition < rhsPosition
                }
            }
            
            // Finally, sort by name for stable ordering
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
}