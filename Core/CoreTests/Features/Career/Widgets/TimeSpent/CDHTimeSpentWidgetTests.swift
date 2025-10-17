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

final class CDHTimeSpentWidgetTests: CoreTestCase {
    func testSave() {
        // Given
        let apiEntity = makeTimeSpent(courseID: "42", courseName: "Course 42", minutesPerDay: 15)
        // When
        let saved = CDHTimeSpentWidget.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(saved.courseID, "42")
        XCTAssertEqual(saved.courseName, "Course 42")
        XCTAssertEqual(saved.minutesPerDay.intValue, 15)
    }

    func testSaveWithNilValues() {
        // Given
        let apiEntity = makeTimeSpent(courseID: nil, courseName: nil, minutesPerDay: nil)
        // When
        let saved = CDHTimeSpentWidget.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(saved.courseID, "")
        XCTAssertEqual(saved.courseName, "")
        XCTAssertEqual(saved.minutesPerDay.intValue, 0)
    }

    func testUpdateExistingEntity() {
        // Given initial save
        let initial = makeTimeSpent(courseID: "99", courseName: "Old Name", minutesPerDay: 10)
        let savedInitial = CDHTimeSpentWidget.save(initial, in: databaseClient)
        XCTAssertEqual(savedInitial.courseName, "Old Name")
        // When saving again with same courseID but new values
        let updated = makeTimeSpent(courseID: "99", courseName: "New Name", minutesPerDay: 25)
        let savedUpdated = CDHTimeSpentWidget.save(updated, in: databaseClient)
        // Then should update existing record (object identity preserved)
        XCTAssertEqual(savedUpdated.objectID, savedInitial.objectID)
        XCTAssertEqual(savedUpdated.courseID, "99")
        XCTAssertEqual(savedUpdated.courseName, "New Name")
        XCTAssertEqual(savedUpdated.minutesPerDay.intValue, 25)
    }

    private func makeTimeSpent(
        courseID: String?,
        courseName: String?,
        minutesPerDay: Int?
    ) -> GetTimeSpentWidgetResponse.TimeSpent {
        return GetTimeSpentWidgetResponse.TimeSpent(
            date: nil,
            userID: nil,
            userUUID: nil,
            userName: nil,
            userEmail: nil,
            userAvatarImageURL: nil,
            courseID: courseID,
            courseName: courseName,
            minutesPerDay: minutesPerDay
        )
    }
}
