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
import Core
@testable import Horizon
import XCTest
import UIKit

final class EditNotebookViewModelTests: HorizonTestCase {
    private var courseNoteInteractor: CourseNoteInteractorMock!
    private var onUpdateNoteCalled: Bool?

    override func setUp() {
        super.setUp()
        courseNoteInteractor = CourseNoteInteractorMock()
        onUpdateNoteCalled = false
    }

    override func tearDown() {
        courseNoteInteractor = nil
        onUpdateNoteCalled = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testInitialization_setsInitialValuesCorrectly() {
        // Given
        let note = CourseNotebookNote.example

        // When
        let viewModel = makeViewModel(courseNotebookNote: note)

        // Then
        XCTAssertEqual(viewModel.note, note.content)
        XCTAssertEqual(viewModel.selectedLabel, note.labels?.first)
        XCTAssertEqual(viewModel.highlightedText, note.highlightData?.selectedText)
        XCTAssertFalse(viewModel.isSaveButtonEnabled)
    }

    func testNoteChange_enablesSaveButton() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.note = "A new note."

        // Then
        XCTAssertTrue(viewModel.isSaveButtonEnabled)
    }

    func testLabelChange_enablesSaveButton() {
        // Given
        let note = CourseNotebookNote(
            id: "1",
            date: Date(),
            courseId: "c1",
            objectId: "o1",
            labels: [.unclear]
        )
        let viewModel = makeViewModel(courseNotebookNote: note)

        // When
        viewModel.selectedLabel = .important

        // Then
        XCTAssertTrue(viewModel.isSaveButtonEnabled)
    }

    func testNoteChange_thenRevert_disablesSaveButton() {
        // Given
        let originalNote = "Original content"
        let note = CourseNotebookNote(
            id: "1",
            date: Date(),
            courseId: "c1",
            objectId: "o1",
            content: originalNote,
            labels: [.unclear]
        )
        let viewModel = makeViewModel(courseNotebookNote: note)

        // When
        viewModel.note = "Something different"
        XCTAssertTrue(viewModel.isSaveButtonEnabled)

        viewModel.note = originalNote

        // Then
        XCTAssertFalse(viewModel.isSaveButtonEnabled)
    }

    func testLabelChange_thenRevert_disablesSaveButton() {
        // Given
        let note = CourseNotebookNote(
            id: "1",
            date: Date(),
            courseId: "c1",
            objectId: "o1",
            content: "content",
            labels: [.unclear]
        )
        let viewModel = makeViewModel(courseNotebookNote: note)

        // When
        viewModel.selectedLabel = .important
        XCTAssertTrue(viewModel.isSaveButtonEnabled)

        viewModel.selectedLabel = .unclear

        // Then
        XCTAssertFalse(viewModel.isSaveButtonEnabled)
    }

    func testUpdate_success_callsInteractorAndDismisses() {
        // Given
        let viewModel = makeViewModel()
        viewModel.note = "Updated note"

        // When
        viewModel.update(viewController: WeakViewController(UIViewController()))

        // Then
        XCTAssertEqual(courseNoteInteractor.setCallCount, 1)
        XCTAssertEqual(
            courseNoteInteractor.lastSetParams?.id,
            CourseNotebookNote.example.id
        )
        XCTAssertEqual(courseNoteInteractor.lastSetParams?.content, "Updated note")
        XCTAssertEqual(courseNoteInteractor.lastSetParams?.labels, [viewModel.selectedLabel])
        XCTAssertEqual(viewModel.state, .data)
        XCTAssertEqual(onUpdateNoteCalled, true)
    }

    func testUpdate_failure_setsErrorState() {
        // Given
        courseNoteInteractor.shouldFailSet = true
        let viewModel = makeViewModel()
        viewModel.note = "Updated note"

        // When
        viewModel.update(viewController: WeakViewController(UIViewController()))

        // Then
        XCTAssertEqual(courseNoteInteractor.setCallCount, 1)
        XCTAssertEqual(viewModel.state, .data)
        XCTAssertTrue(viewModel.isErrorMessagePresented)
        XCTAssertEqual(onUpdateNoteCalled, false)
    }

    func testDelete_success_callsInteractorAndDismisses() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.deleteNoteAndDismiss(viewController: WeakViewController(UIViewController()))

        // Then
        XCTAssertEqual(courseNoteInteractor.deleteCallCount, 1)
        XCTAssertEqual(
            courseNoteInteractor.lastDeletedId,
            CourseNotebookNote.example.id
        )
        XCTAssertEqual(viewModel.state, .data)
    }

    func testDelete_failure_setsErrorState() {
        // Given
        courseNoteInteractor.shouldFailDelete = true

        let viewModel = makeViewModel()

        // When
        viewModel.deleteNoteAndDismiss(viewController: WeakViewController(UIViewController()))

        // Then
        XCTAssertEqual(courseNoteInteractor.deleteCallCount, 1)
        XCTAssertEqual(viewModel.state, .data)
        XCTAssertTrue(viewModel.isErrorMessagePresented)
    }

    func testClose_callsRouterDismiss() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.close(WeakViewController(UIViewController()))

        // Then
        XCTAssertNotNil(router.dismissed)
    }

    // MARK: - Helpers

    private func makeViewModel(
        courseNotebookNote: CourseNotebookNote = .example
    ) -> EditNotebookViewModel {
        EditNotebookViewModel(
            courseNoteInteractor: courseNoteInteractor,
            router: router,
            courseNotebookNote: courseNotebookNote,
            scheduler: .immediate,
            onUpdateNote: { [weak self] _ in
                self?.onUpdateNoteCalled = true
            }
        )
    }
}
