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

final class NotebookListViewModelTests: HorizonTestCase {

    private var courseNoteInteractor: CourseNoteInteractorMock!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        courseNoteInteractor = CourseNoteInteractorMock()
        testScheduler = TestScheduler(now: DispatchQueue.SchedulerTimeType(DispatchTime.now()))
    }

    override func tearDown() {
        courseNoteInteractor = nil
        testScheduler = nil
        super.tearDown()
    }

    // MARK: - Init

    func testInitialization_fetchesNotesAndSetsInitialState() {
        // Given
        let notes = (1...15).map { CourseNotebookNote.make(id: "\($0)") }
        let courses = [DropdownMenuItem(id: "1", name: "Course 1")]
        courseNoteInteractor.getAllNotesWithCoursesResult = .init(notes: notes, courses: courses)

        // When
        let viewModel = makeViewModel()
        testScheduler.advance()

        // Then
        XCTAssertEqual(viewModel.filteredNotes.count, 10)
        XCTAssertEqual(viewModel.courses, courses)
        XCTAssertEqual(viewModel.state, .data)
        XCTAssertTrue(viewModel.listState.isSeeMoreButtonVisible)
    }

    func testInitialization_whenNoNotes_setsEmptyState() {
        // Given
        courseNoteInteractor.getAllNotesWithCoursesResult = .init(notes: [], courses: [])

        // When
        let viewModel = makeViewModel()
        testScheduler.advance()

        // Then
        XCTAssertTrue(viewModel.filteredNotes.isEmpty)
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertFalse(viewModel.listState.isSeeMoreButtonVisible)
    }

    // MARK: - Pagination

    func testSeeMore_appendsNextPageOfNotes() {
        // Given
        let notes = (1...25).map { CourseNotebookNote.make(id: "\($0)") }
        courseNoteInteractor.getAllNotesWithCoursesResult = .init(notes: notes, courses: [])
        let viewModel = makeViewModel()
        testScheduler.advance()

        XCTAssertEqual(viewModel.filteredNotes.count, 10)
        XCTAssertTrue(viewModel.listState.isSeeMoreButtonVisible)

        // When
        viewModel.seeMore()

        // Then
        XCTAssertEqual(viewModel.filteredNotes.count, 20)
        XCTAssertTrue(viewModel.listState.isSeeMoreButtonVisible)

        // When
        viewModel.seeMore()

        // Then
        XCTAssertEqual(viewModel.filteredNotes.count, 25)
        XCTAssertFalse(viewModel.listState.isSeeMoreButtonVisible)
    }

    // MARK: - Deletion

    func testDeleteNote_onSuccess_removesNoteFromList() {
        // Given
        let notes = (1...5).map { CourseNotebookNote.make(id: "\($0)") }
        courseNoteInteractor.getAllNotesWithCoursesResult = .init(notes: notes, courses: [])
        let viewModel = makeViewModel()
        testScheduler.advance()

        let noteToDelete = notes[2] // id: "3"
        XCTAssertTrue(viewModel.filteredNotes.contains(where: { $0.id == "3" }))

        // When
        viewModel.deleteNote(noteToDelete)
        testScheduler.advance()

        // Then
        XCTAssertEqual(courseNoteInteractor.deleteCallCount, 1)
        XCTAssertEqual(courseNoteInteractor.lastDeletedId, "3")
        XCTAssertFalse(viewModel.filteredNotes.contains(where: { $0.id == "3" }))
    }

    func testDeleteNote_onFailure_showsError() {
        // Given
        let notes = (1...5).map { CourseNotebookNote.make(id: "\($0)") }
        courseNoteInteractor.getAllNotesWithCoursesResult = .init(notes: notes, courses: [])
        courseNoteInteractor.shouldFailDelete = true
        let viewModel = makeViewModel()
        testScheduler.advance()

        // When
        viewModel.deleteNote(notes[0])
        testScheduler.advance()

        // Then
        XCTAssertTrue(viewModel.listState.isPresentedErrorToast)
        XCTAssertNotNil(viewModel.listState.errorMessage)
    }

    // MARK: - Filtering

    func testFilter_fetchesNotesWithCorrectFilter() {
        // Given
        let viewModel = makeViewModel()
        let selectedCourse = DropdownMenuItem(id: "course-filter-id", name: "All Courses")
        let selectedLabel = CourseNoteLabel.list.first(where: { $0.key == "Important" })!

        viewModel.listState.selectedCourse = selectedCourse
        viewModel.listState.selectedLable = selectedLabel

        // When
        viewModel.filter()
        testScheduler.advance()

        // Then
        XCTAssertEqual(courseNoteInteractor.lastFilter?.courseId, "course-filter-id")
        XCTAssertEqual(courseNoteInteractor.lastFilter?.reactions, ["Important"])
    }

    // MARK: - Routing

    func testGoToModuleItem_callsRouter() {
        // Given
        let viewModel = makeViewModel()
        let note = CourseNotebookNote.make(courseId: "466", objectId: "1171")

        // When
        viewModel.goToModuleItem(note, viewController: WeakViewController(UIViewController()))
        wait(for: [router.routeExpectation], timeout: 1)
        // Then
        XCTAssertEqual(router.calls.last?.0, URLComponents(string: "/courses/466/modules/items/1171?asset_type=Page&notebook_disabled=true&scrollToNoteID=noteID"))
    }

    func testPresentEditNote_callsRouter() {
        // Given
        let viewModel = makeViewModel()
        let note = CourseNotebookNote.make()

        // When
        viewModel.presentEditNote(note: note, viewController: WeakViewController(UIViewController()))
        let editNotebookView = router.lastViewController as? CoreHostingController<Horizon.EditNotebookView>

        // Then
        XCTAssertNotNil(editNotebookView)
    }

    func testGoBack() {
        let viewModel = makeViewModel()

        // When
        viewModel.goBack(WeakViewController(UIViewController()))

        // Then
        XCTAssertNotNil(router.popped)
    }

    // MARK: - Helpers

    private func makeViewModel(
        pageURL: String? = nil,
        courseID: String? = "123"
    ) -> NotebookListViewModel {
        return NotebookListViewModel(
            pageURL: pageURL,
            courseID: courseID,
            interactor: courseNoteInteractor,
            scheduler: testScheduler.eraseToAnyScheduler(),
            router: router
        )
    }
}

// Helper extension to create mock notes easily
fileprivate extension CourseNotebookNote {
    static func make(
        id: String = "noteID",
        date: Date = Date(),
        courseId: String = "courseID",
        courseName: String? = "Course Name",
        objectId: String = "objectID",
        content: String? = "Note content",
        highlightData: NotebookHighlight? = nil,
        labels: [CourseNoteLabel]? = [.important]
    ) -> CourseNotebookNote {
        .init(
            id: id,
            date: date,
            courseId: courseId,
            courseName: courseName,
            objectId: objectId,
            content: content,
            highlightData: highlightData,
            labels: labels
        )
    }
}
