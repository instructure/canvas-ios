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
import CoreData
import TestsFoundation
@testable import Core
@testable import Teacher

final class DifferentiationTagsComparatorTests: TeacherTestCase {

    func testSort() {
        // Create group sets
        let visualLearningSet = createGroupSet(id: "visual", name: "Visual Learning")
        let academicSupportSet = createGroupSet(id: "academic", name: "Academic Support")
        let extendedTimeSet = createGroupSet(id: "extended", name: "Extended Time")
        let mathSupportSet = createGroupSet(id: "math", name: "Math Support")

        // Create single tags (ungrouped - where tag name equals group set name)
        let singleExtendedTime = createUserGroup(id: "single-extended", name: "Extended Time", groupSet: extendedTimeSet)
        let singleMathSupport = createUserGroup(id: "single-math", name: "Math Support", groupSet: mathSupportSet)
        let singleAcademicSupport = createUserGroup(id: "single-academic", name: "Academic Support", groupSet: academicSupportSet)

        // Create grouped tags (where tag name differs from group set name)
        let tutoring = createUserGroup(id: "tutoring", name: "Tutoring", groupSet: academicSupportSet)
        let extraHelp = createUserGroup(id: "extra-help", name: "Extra Help", groupSet: academicSupportSet)
        let colorCoding = createUserGroup(id: "color-coding", name: "Color Coding", groupSet: visualLearningSet)
        let charts = createUserGroup(id: "charts", name: "Charts", groupSet: visualLearningSet)

        // Mix them up in random order
        let unsortedTags = [colorCoding, singleMathSupport, extraHelp, singleExtendedTime, charts, tutoring, singleAcademicSupport]

        // Sort using the comparator
        let sortedTags = unsortedTags.sorted(by: DifferentiationTagsComparator)

        // Expected order:
        // 1. Single tags first, alphabetically:
        //    - Academic Support (single)
        //    - Extended Time (single) 
        //    - Math Support (single)
        // 2. Grouped tags, by group name then tag name:
        //    - Academic Support group: Extra Help, Tutoring
        //    - Visual Learning group: Charts, Color Coding

        XCTAssertEqual(sortedTags.count, 7)

        // Single tags first (alphabetically)
        XCTAssertEqual(sortedTags[0].name, "Academic Support")
        XCTAssertTrue(sortedTags[0].isSingleTag)

        XCTAssertEqual(sortedTags[1].name, "Extended Time")
        XCTAssertTrue(sortedTags[1].isSingleTag)

        XCTAssertEqual(sortedTags[2].name, "Math Support")
        XCTAssertTrue(sortedTags[2].isSingleTag)

        // Grouped tags by group name, then tag name
        XCTAssertEqual(sortedTags[3].name, "Extra Help")
        XCTAssertEqual(sortedTags[3].parentGroupSet.name, "Academic Support")
        XCTAssertFalse(sortedTags[3].isSingleTag)

        XCTAssertEqual(sortedTags[4].name, "Tutoring")
        XCTAssertEqual(sortedTags[4].parentGroupSet.name, "Academic Support")
        XCTAssertFalse(sortedTags[4].isSingleTag)

        XCTAssertEqual(sortedTags[5].name, "Charts")
        XCTAssertEqual(sortedTags[5].parentGroupSet.name, "Visual Learning")
        XCTAssertFalse(sortedTags[5].isSingleTag)

        XCTAssertEqual(sortedTags[6].name, "Color Coding")
        XCTAssertEqual(sortedTags[6].parentGroupSet.name, "Visual Learning")
        XCTAssertFalse(sortedTags[6].isSingleTag)
    }

    // MARK: - Helpers

    private func createGroupSet(id: String, name: String) -> CDUserGroupSet {
        let groupSet: CDUserGroupSet = databaseClient.insert()
        groupSet.id = id
        groupSet.name = name
        groupSet.courseId = "test-course"
        return groupSet
    }

    private func createUserGroup(id: String, name: String, groupSet: CDUserGroupSet) -> CDUserGroup {
        let userGroup: CDUserGroup = databaseClient.insert()
        userGroup.id = id
        userGroup.name = name
        userGroup.isDifferentiationTag = true
        userGroup.parentGroupSet = groupSet
        userGroup.userIdsInGroup = Set()
        return userGroup
    }
}
