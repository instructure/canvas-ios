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

final class CDHNotebookNoteTests: CoreTestCase {
    func testInitialization() {
        let note = CDHNotebookNote(context: databaseClient)
        note.id = "note-123"
        note.courseID = "course-456"
        note.pageID = "page-789"
        note.objectType = "note"
        note.content = "This is a test note"
        note.date = Date()
        note.userID = "user-101"
        note.labels = "important;urgent"
        note.selectedText = "selected text"
        note.start = 10
        note.startContainer = "container1"
        note.startOffset = 5
        note.end = 20
        note.endContainer = "container2"
        note.endOffset = 15
        note.after = "after-token"
        note.before = "before-token"

        try? databaseClient.save()

        let fetchedNote: CDHNotebookNote? = databaseClient.first(where: #keyPath(CDHNotebookNote.id), equals: "note-123")

        XCTAssertNotNil(fetchedNote)
        XCTAssertEqual(fetchedNote?.id, "note-123")
        XCTAssertEqual(fetchedNote?.courseID, "course-456")
        XCTAssertEqual(fetchedNote?.pageID, "page-789")
        XCTAssertEqual(fetchedNote?.objectType, "note")
        XCTAssertEqual(fetchedNote?.content, "This is a test note")
        XCTAssertEqual(fetchedNote?.userID, "user-101")
        XCTAssertEqual(fetchedNote?.labels, "important;urgent")
        XCTAssertEqual(fetchedNote?.selectedText, "selected text")
        XCTAssertEqual(fetchedNote?.start, 10)
        XCTAssertEqual(fetchedNote?.startContainer, "container1")
        XCTAssertEqual(fetchedNote?.startOffset, 5)
        XCTAssertEqual(fetchedNote?.end, 20)
        XCTAssertEqual(fetchedNote?.endContainer, "container2")
        XCTAssertEqual(fetchedNote?.endOffset, 15)
        XCTAssertEqual(fetchedNote?.after, "after-token")
        XCTAssertEqual(fetchedNote?.before, "before-token")
    }

    func testDeserializeLabels() {
        XCTAssertEqual(CDHNotebookNote.deserializeLabels(from: "tag1;tag2;tag3"), ["tag1", "tag2", "tag3"])
        XCTAssertNil(CDHNotebookNote.deserializeLabels(from: nil))
        XCTAssertEqual(CDHNotebookNote.deserializeLabels(from: "tag1"), ["tag1"])
    }

    func testSerializeLabels() {
        XCTAssertEqual(CDHNotebookNote.serializeLabels(from: ["tag2", "tag1", "tag3"]), "tag1;tag2;tag3")
        XCTAssertEqual(CDHNotebookNote.serializeLabels(from: []), "")
        XCTAssertEqual(CDHNotebookNote.serializeLabels(from: ["tag1"]), "tag1")
    }

    func testFetchByID() {
        let note = CDHNotebookNote(context: databaseClient)
        note.id = "fetch-test-123"
        note.courseID = "course-456"
        note.pageID = "page-789"
        note.objectType = "note"
        note.date = Date()

        try? databaseClient.save()

        let fetchedNote: CDHNotebookNote? = databaseClient.fetch(scope: .where(#keyPath(CDHNotebookNote.id), equals: "fetch-test-123")).first

        XCTAssertNotNil(fetchedNote)
        XCTAssertEqual(fetchedNote?.id, "fetch-test-123")
    }

    func testUpdateNote() {
        let note = CDHNotebookNote(context: databaseClient)
        note.id = "update-test-123"
        note.courseID = "course-456"
        note.pageID = "page-789"
        note.objectType = "note"
        note.content = "Original content"
        note.date = Date()
        note.labels = "original"

        try? databaseClient.save()

        let fetchedNote: CDHNotebookNote? = databaseClient.first(where: #keyPath(CDHNotebookNote.id), equals: "update-test-123")
        XCTAssertNotNil(fetchedNote)

        fetchedNote?.content = "Updated content"
        fetchedNote?.labels = "updated;new"

        try? databaseClient.save()

        let updatedNote: CDHNotebookNote? = databaseClient.first(where: #keyPath(CDHNotebookNote.id), equals: "update-test-123")

        XCTAssertNotNil(updatedNote)
        XCTAssertEqual(updatedNote?.content, "Updated content")
        XCTAssertEqual(updatedNote?.labels, "updated;new")
        XCTAssertEqual(CDHNotebookNote.deserializeLabels(from: updatedNote?.labels), ["updated", "new"])
    }
}
