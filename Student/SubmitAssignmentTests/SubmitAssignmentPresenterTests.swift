//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import Core
import TestsFoundation
import CoreData

class SubmitAssignmentPresenterTests: SubmitAssignmentTests, SubmitAssignmentView {
    class TestExtensionItem: NSExtensionItem {
        var mocks: [NSItemProvider]?
        init(mockAttachments: [NSItemProvider]?) {
            self.mocks = mockAttachments
            super.init()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var attachments: [NSItemProvider]? {
            get { return mocks }
            set { mocks = newValue }
        }
    }

    class ErrorItem: NSItemProvider {
        override func loadFileRepresentation(forTypeIdentifier typeIdentifier: String, completionHandler: @escaping (URL?, Error?) -> Void) -> Progress {
            completionHandler(nil, NSError.instructureError("doh"))
            return .discreteProgress(totalUnitCount: 1)
        }
    }

    var presenter: SubmitAssignmentPresenter!

    override func setUp() {
        super.setUp()
        LoginSession.add(.make())
        presenter = SubmitAssignmentPresenter()
        presenter.view = self
        presenter.uploadManager = uploadManager
        // SubmitAssignmentPresenter calls env.userDidLogin, so need to reset after
        env.api = URLSessionAPI()
        env.database = database
        env.userDefaults?.reset()
    }

    func testInitNilWithoutRecentSession() {
        let sessions = LoginSession.sessions
        LoginSession.clearAll()
        XCTAssertNil(SubmitAssignmentPresenter())
        LoginSession.sessions = sessions
    }

    func testInitValid() {
        XCTAssertNotNil(LoginSession.mostRecent)
        XCTAssertNotNil(SubmitAssignmentPresenter())
    }

    func testViewIsReady() {
        Course.make(from: .make(id: "1"))
        Assignment.make(from: .make(course_id: "1", submission_types: [.online_upload]))
        let expectation = XCTestExpectation(description: "got course and assignment")
        expectation.assertForOverFulfill = false
        onUpdate = {
            if self.presenter.course != nil && self.presenter.assignment != nil {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
    }

    func testAutoSelectsUserDefaults() {
        env.userDefaults?.submitAssignmentCourseID = "1"
        env.userDefaults?.submitAssignmentID = "2"
        Course.make(from: .make(id: "0", name: "A"))
        Course.make(from: .make(id: "1", name: "B"))
        Assignment.make(from: .make(id: "0", course_id: "1", name: "AA"))
        Assignment.make(from: .make(id: "2", course_id: "1", name: "BB"))
        let expectation = XCTestExpectation(description: "got default course and assignment")
        expectation.assertForOverFulfill = false
        onUpdate = {
            if self.presenter.course != nil && self.presenter.assignment != nil {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
    }

    func testSelectCourse() {
        let expectation = XCTestExpectation(description: "course updated")
        onUpdate = {
            if self.presenter.course?.name == "Selected Course" {
                expectation.fulfill()
            }
        }
        presenter.select(course: Course.make(from: .make(name: "Selected Course")))
        wait(for: [expectation], timeout: 0.1)
    }

    func testSelectAssignment() {
        let expectation = XCTestExpectation(description: "assignment updated")
        onUpdate = {
            if self.presenter.assignment?.name == "Selected Assignment" {
                expectation.fulfill()
            }
        }
        presenter.select(assignment: Assignment.make(from: .make(name: "Selected Assignment")))
        wait(for: [expectation], timeout: 0.1)
    }

    func testLoadItemsContentIsValid() {
        XCTAssertFalse(presenter.isContentValid)
        presenter.select(course: .make())
        XCTAssertFalse(presenter.isContentValid)
        presenter.select(assignment: .make())
        XCTAssertFalse(presenter.isContentValid)
        let expectation = XCTestExpectation(description: "content is valid")
        onUpdate = {
            if self.presenter.isContentValid {
                expectation.fulfill()
            }
        }
        let attachment = NSItemProvider(item: Data() as NSSecureCoding, typeIdentifier: UTI.any.rawValue)
        let item = TestExtensionItem(mockAttachments: [attachment])
        presenter.load(items: [item])
        wait(for: [expectation], timeout: 5)
    }

    func testLoadItemsImage() {
        presenter.select(course: .make())
        presenter.select(assignment: .make())
        let expectation = XCTestExpectation(description: "content is valid")
        onUpdate = {
            if self.presenter.isContentValid {
                expectation.fulfill()
            }
        }
        let attachment = NSItemProvider(item: UIImage.icon(.addImageLine), typeIdentifier: UTI.image.rawValue)
        let item = TestExtensionItem(mockAttachments: [attachment])
        presenter.load(items: [item])
        wait(for: [expectation], timeout: 1)
    }

    func testLoadItemsFileURL() throws {
        let fileURL = URL.temporaryDirectory.appendingPathComponent("loadFileURL.txt", isDirectory: false)
        try "test".write(to: fileURL, atomically: false, encoding: .utf8)
        presenter.select(course: .make())
        presenter.select(assignment: .make())
        let expectation = XCTestExpectation(description: "content is valid")
        onUpdate = {
            if self.presenter.isContentValid {
                expectation.fulfill()
            }
        }
        let attachment = NSItemProvider(item: fileURL as NSSecureCoding, typeIdentifier: UTI.fileURL.rawValue)
        let item = TestExtensionItem(mockAttachments: [attachment])
        presenter.load(items: [item])
        wait(for: [expectation], timeout: 1)
        try FileManager.default.removeItem(at: fileURL)
    }

    func testSubmit() {
        presenter.select(course: Course.make())
        presenter.select(assignment: Assignment.make())
        let expectation = XCTestExpectation(description: "content is valid")
        onUpdate = {
            if self.presenter.isContentValid {
                expectation.fulfill()
            }
        }
        let attachment = NSItemProvider(item: Data() as NSSecureCoding, typeIdentifier: UTI.any.rawValue)
        let item = TestExtensionItem(mockAttachments: [attachment])
        presenter.load(items: [item])
        wait(for: [expectation], timeout: 0.5)
        let callback = XCTestExpectation(description: "callback was called")
        presenter.submit(comment: nil) { callback.fulfill() }
        wait(for: [callback], timeout: 1)
        XCTAssertTrue(uploadManager.cancelWasCalled)
        XCTAssertTrue(uploadManager.uploadWasCalled)
    }

    var onUpdate: () -> Void = {}
    func update() {
        onUpdate()
    }
}
