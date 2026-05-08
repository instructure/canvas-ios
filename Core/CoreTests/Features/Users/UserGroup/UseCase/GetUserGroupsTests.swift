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

import Foundation
import XCTest
@testable import Core

class GetUserGroupsTests: CoreTestCase {
    func testGetUserGroupsFilteringBehavior() {
        let courseId = "course-123"

        // Group Set 1: Contains only collaborative groups (non-differentiation)
        let collaborativeGroupSet = CDUserGroupSet(context: database.viewContext)
        collaborativeGroupSet.id = "collaborative-groupset"
        collaborativeGroupSet.name = "Collaborative Project Groups"
        collaborativeGroupSet.courseId = courseId

        let collaborativeGroup = CDUserGroup(context: database.viewContext)
        collaborativeGroup.id = "collaborative-team-alpha"
        collaborativeGroup.name = "Collaborative Team Alpha"
        collaborativeGroup.isDifferentiationTag = false
        collaborativeGroup.userIdsInGroup = Set(["student1", "student2"])
        collaborativeGroup.parentGroupSet = collaborativeGroupSet

        // Group Set 2: Contains both collaborative groups and differentiation tags (mixed)
        let mixedGroupSet = CDUserGroupSet(context: database.viewContext)
        mixedGroupSet.id = "mixed-groupset"
        mixedGroupSet.name = "Study Groups & Differentiation Tags"
        mixedGroupSet.courseId = courseId

        let collaborativeStudyGroup = CDUserGroup(context: database.viewContext)
        collaborativeStudyGroup.id = "collaborative-study-group"
        collaborativeStudyGroup.name = "Collaborative Evening Study Group"
        collaborativeStudyGroup.isDifferentiationTag = false
        collaborativeStudyGroup.userIdsInGroup = Set(["student3", "student4"])
        collaborativeStudyGroup.parentGroupSet = mixedGroupSet

        let differentiationTag = CDUserGroup(context: database.viewContext)
        differentiationTag.id = "differentiation-tag-visual"
        differentiationTag.name = "Differentiation Tag: Visual Learners"
        differentiationTag.isDifferentiationTag = true
        differentiationTag.userIdsInGroup = Set(["student1", "student3"])
        differentiationTag.parentGroupSet = mixedGroupSet

        try! database.viewContext.save()

        // MARK: - WHEN (Filtered)
        let filteredUseCase = GetUserGroups(courseId: courseId, filterToDifferentiationTags: true)
        let filteredGroups: [CDUserGroup] = database.viewContext.fetch(scope: filteredUseCase.scope)

        // MARK: - THEN (Filtered)
        XCTAssertEqual(filteredGroups.count, 1)
        XCTAssertEqual(filteredGroups.first?.id, "differentiation-tag-visual")
        XCTAssertTrue(filteredGroups.first?.isDifferentiationTag == true)

        // MARK: - WHEN (Unfiltered)
        let unfilteredUseCase = GetUserGroups(courseId: courseId, filterToDifferentiationTags: false)
        let allGroups: [CDUserGroup] = database.viewContext.fetch(scope: unfilteredUseCase.scope)

        // MARK: - THEN (Unfiltered)
        XCTAssertEqual(allGroups.count, 3)
        let allGroupIds = Set(allGroups.map { $0.id })
        XCTAssertTrue(allGroupIds.contains("collaborative-team-alpha"))
        XCTAssertTrue(allGroupIds.contains("collaborative-study-group"))
        XCTAssertTrue(allGroupIds.contains("differentiation-tag-visual"))
    }
}
