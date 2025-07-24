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
@testable import Teacher
import TestsFoundation

class StudentNotesViewModelTests: TeacherTestCase {

    private static let testData = (
        userId: "some userId",
        entry1: StudentNotesEntry(index: 1, title: "title 1", content: "content 1"),
        entry2: StudentNotesEntry(index: 2, title: "title 2", content: "content 2")
    )
    private lazy var testData = Self.testData

    private var interactor: CustomGradebookColumnsInteractorMock!

    override func setUp() {
        super.setUp()

        interactor = .init()
    }

    override func tearDown() {
        interactor = nil
        super.tearDown()
    }

    func test_init_shouldCallInteractorWithUserId() {
        _ = makeViewModel()

        XCTAssertEqual(interactor.getStudentNotesEntriesCallsCount, 1)
        XCTAssertEqual(interactor.getStudentNotesEntriesInput, testData.userId)
    }

    func test_entries_whenInteractorReturnsOneEntry() {
        interactor.getStudentNotesEntriesOutputValue = [testData.entry1]
        let testee = makeViewModel()

        XCTAssertEqual(testee.entries, [testData.entry1])
        XCTAssertEqual(testee.hasContent, true)
    }

    func test_entries_whenInteractorReturnsMultipleEntries() {
        interactor.getStudentNotesEntriesOutputValue = [testData.entry1, testData.entry2]
        let testee = makeViewModel()

        XCTAssertEqual(testee.entries, [testData.entry1, testData.entry2])
        XCTAssertEqual(testee.hasContent, true)
    }

    func test_entries_whenInteractorReturnsNoEntries() {
        interactor.getStudentNotesEntriesOutputValue = []
        let testee = makeViewModel()

        XCTAssertEqual(testee.entries, [])
        XCTAssertEqual(testee.hasContent, false)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        userId: String = testData.userId,
    ) -> StudentNotesViewModel {
        .init(
            userId: userId,
            interactor: interactor,
            scheduler: .immediate
        )
    }
}
