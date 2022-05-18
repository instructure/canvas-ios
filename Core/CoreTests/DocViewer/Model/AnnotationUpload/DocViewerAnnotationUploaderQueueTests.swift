//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class DocViewerAnnotationUploaderQueueTests: XCTestCase {

    func testAddTaskMethods() {
        let testee = DocViewerAnnotationUploaderQueue()

        testee.put(.make())
        testee.delete("123")

        XCTAssertEqual(testee.tasks[0], .put(.make()))
        XCTAssertEqual(testee.tasks[1], .delete(annotationID: "123"))
    }

    func testRequestTask() {
        let testee = DocViewerAnnotationUploaderQueue()
        testee.put(.make())
        XCTAssertEqual(testee.tasks.count, 1)

        let receivedTask = testee.requestTask()

        XCTAssertEqual(receivedTask, .put(.make()))
        XCTAssertEqual(testee.tasks.count, 0)
    }

    func testPutRemovesOldTasksForTheSameAnnotationID() {
        let testee = DocViewerAnnotationUploaderQueue()
        testee.put(.make(id: "1", coords: [[[0, 0]]]))
        testee.put(.make(id: "2"))
        testee.delete("1")
        testee.delete("3")

        testee.put(.make(id: "1", coords: [[[1, 1]]]))

        XCTAssertEqual(testee.tasks.count, 3)
        XCTAssertEqual(testee.tasks[0], .put(.make(id: "2")))
        XCTAssertEqual(testee.tasks[1], .delete(annotationID: "3"))
        XCTAssertEqual(testee.tasks[2], .put(.make(id: "1", coords: [[[1, 1]]])))
    }

    func testDeleteRemovesOldTasksForTheSameAnnotationID() {
        let testee = DocViewerAnnotationUploaderQueue()
        testee.put(.make(id: "1", coords: [[[0, 0]]]))
        testee.delete("1")
        testee.delete("2")
        testee.put(.make(id: "3"))

        testee.delete("1")

        XCTAssertEqual(testee.tasks.count, 3)
        XCTAssertEqual(testee.tasks[0], .delete(annotationID: "2"))
        XCTAssertEqual(testee.tasks[1], .put(.make(id: "3")))
        XCTAssertEqual(testee.tasks[2], .delete(annotationID: "1"))
    }

    func testInsertTask() {
        let testee = DocViewerAnnotationUploaderQueue()
        testee.delete("1")

        let isInserted = testee.insertTaskIfNecessary(.put(.make(id: "2")))

        XCTAssertEqual(testee.tasks.count, 2)
        XCTAssertEqual(testee.tasks, [.put(.make(id: "2")), .delete(annotationID: "1")])
        XCTAssertTrue(isInserted)
    }

    func testDoesntInsertTaskIfThereIsAnotherForTheSameAnnotation() {
        let testee = DocViewerAnnotationUploaderQueue()
        testee.delete("1")

        let isInserted = testee.insertTaskIfNecessary(.put(.make(id: "1")))

        XCTAssertEqual(testee.tasks.count, 1)
        XCTAssertEqual(testee.tasks, [.delete(annotationID: "1")])
        XCTAssertFalse(isInserted)
    }
}
