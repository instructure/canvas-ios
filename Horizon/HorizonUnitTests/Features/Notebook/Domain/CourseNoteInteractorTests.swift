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
import TestsFoundation
@testable import Horizon
@testable import Core

final class CourseNoteInteractorTests: HorizonTestCase {

    // MARK: - Properties

    private var learnCoursesInteractor: GetLearnCoursesInteractorMock!
    private var interactor: CourseNoteInteractorLive!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        learnCoursesInteractor = GetLearnCoursesInteractorMock()
        interactor = CourseNoteInteractorLive(learnCoursesInteractor: learnCoursesInteractor)
    }

    override func tearDown() {
        learnCoursesInteractor = nil
        interactor = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeInteractorWithAPI() {
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .journey),
            value: .init(token: HTimeSpentWidgetStubs.token)
        )

        interactor = CourseNoteInteractorLive(
            learnCoursesInteractor: learnCoursesInteractor,
            domainService: DomainServiceMock(result: .success(api))
        )
    }

    func testDeleteNote() {
        // Given
        makeInteractorWithAPI()

        let noteID = "note-to-delete"
        api.mock(
            RedwoodDeleteNoteMutation(id: noteID),
            value: RedwoodDeleteNoteMutationResponse(data: .init(deleteNote: "deleted Note"))
        )

        // When
        let publisher = interactor.delete(id: noteID)

        // Then
        XCTAssertSingleOutputAndFinish(publisher) { _ in }
    }

    func testSetNote() {
        // Given
        makeInteractorWithAPI()

        let noteID = "note-1"
        let updatedContent = "This is the updated content."
        let updatedLabels = [CourseNoteLabel.important]

        let highlight = NotebookHighlight(
            selectedText: "Selected Text",
            textPosition: .init(start: 10, end: 100),
            range: .init(
                startContainer: "startContainer",
                startOffset: 10,
                endContainer: "100",
                endOffset: 10
            )
        )

        let request = RedwoodUpdateNoteMutation(
            id: noteID,
            userText: updatedContent,
            reaction: updatedLabels.map(\.rawValue),
            highlightData: .init(
                selectedText: "Selected Text",
                textPosition: .init(start: 10, end: 100),
                range: .init(
                    startContainer: "startContainer",
                    startOffset: 10,
                    endContainer: "100",
                    endOffset: 10
                )
            )
        )

        api.mock(request, value: RedwoodUpdateNoteMutationResponse(data: .init(updateNote: RedwoodNote.make())))

        // When
        let publisher = interactor.set(
            id: noteID,
            content: updatedContent,
            labels: updatedLabels,
            highlightData: highlight
        )

        // Then
        XCTAssertSingleOutputAndFinish(publisher) { note in
            XCTAssertEqual(note.id, noteID)
            XCTAssertEqual(note.labels, updatedLabels)
        }
    }

    func testGetAllNotesWithCourses() {
        // Given
        makeInteractorWithAPI()

        let filter = NotebookQueryFilter()

        let response = RedwoodFetchNotesQueryResponse(
            data: .init(
                notes: .init(
                    edges: [.init(node: RedwoodNote.make(), cursor: "")],
                    pageInfo: .init(
                        hasNextPage: false,
                        hasPreviousPage: false,
                        endCursor: nil,
                        startCursor: nil
                    )
                )
            )
        )

        api.mock(GetNotesQuery(), value: response)

        // When
        let publisher = interactor.getAllNotesWithCourses(
            pageURL: nil,
            ignoreCache: false,
            keepObserving: false,
            filter: filter
        )

        // Then
        XCTAssertSingleOutputAndFinish(publisher) { result in
            XCTAssertEqual(result.notes.count, 1)
            XCTAssertEqual(result.courses.count, 4)
        }
    }
}
