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

final class CDHActivitiesWidgetTests: CoreTestCase {
    func testSave() {
        // Given
        let apiEntity = makeActivitiesWidget(courseID: 42, courseName: "Course 42", moduleCountCompleted: 15)
        // When
        let saved = CDHActivitiesWidget.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(saved.courseID, "42")
        XCTAssertEqual(saved.courseName, "Course 42")
        XCTAssertEqual(saved.moduleCountCompleted.intValue, 15)
    }

    func testSaveWithNilValues() {
        // Given
        let apiEntity = makeActivitiesWidget(courseID: nil, courseName: nil, moduleCountCompleted: nil)
        // When
        let saved = CDHActivitiesWidget.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(saved.courseID, "0")
        XCTAssertEqual(saved.courseName, "")
        XCTAssertEqual(saved.moduleCountCompleted.intValue, 0)
    }

    func testUpdateExistingEntity() {
        // Given
        let initial = makeActivitiesWidget(courseID: 99, courseName: "Old Name", moduleCountCompleted: 10)
        let savedInitial = CDHActivitiesWidget.save(initial, in: databaseClient)
        XCTAssertEqual(savedInitial.courseName, "Old Name")
        // When
        let updated = makeActivitiesWidget(courseID: 99, courseName: "New Name", moduleCountCompleted: 25)
        let savedUpdated = CDHActivitiesWidget.save(updated, in: databaseClient)
        // Then
        XCTAssertEqual(savedUpdated.courseID, "99")
        XCTAssertEqual(savedUpdated.courseName, "New Name")
        XCTAssertEqual(savedUpdated.moduleCountCompleted.intValue, 25)
    }

    private func makeActivitiesWidget(
        courseID: Int?,
        courseName: String?,
        moduleCountCompleted: Int?
    ) -> GetActivitiesWidgetResponse.Widget {
        return .init(
            courseID: courseID,
            courseName: courseName,
            userID: nil,
            userUUID: nil,
            userName: nil,
            userAvatarImageURL: nil,
            userEmail: nil,
            moduleCountCompleted: moduleCountCompleted,
            moduleCountStarted: nil,
            moduleCountLocked: nil,
            moduleCountTotal: nil
        )
    }
}
