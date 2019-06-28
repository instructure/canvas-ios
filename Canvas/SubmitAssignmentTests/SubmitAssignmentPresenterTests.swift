//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        presenter = SubmitAssignmentPresenter()
        presenter.view = self
        super.setUp()
    }

    func testInitNilWithoutRecentSession() {
        let entries = Keychain.entries
        Keychain.clearEntries()
        XCTAssertNil(SubmitAssignmentPresenter())
        entries.forEach { Keychain.addEntry($0) }
    }

    func testInitValid() {
        XCTAssertNotNil(Keychain.mostRecentSession)
        XCTAssertNotNil(SubmitAssignmentPresenter())
    }

    func testViewIsReady() {
        Assignment.make(from: .make(course_id: ID(stringLiteral: Course.make().id)))
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
        presenter.select(assignment: Assignment.make())
        XCTAssertFalse(presenter.isContentValid)
        presenter.select(course: Course.make())
        XCTAssertFalse(presenter.isContentValid)
        let expectation = XCTestExpectation(description: "content is valid")
        onUpdate = {
            if self.presenter.isContentValid {
                expectation.fulfill()
            }
        }
        let attachment = NSItemProvider(contentsOf: URL(string: "data:text/plain,abcde")!)!
        let item = TestExtensionItem(mockAttachments: [attachment])
        presenter.load(items: [item])
        wait(for: [expectation], timeout: 0.5)
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
        let attachment = NSItemProvider(contentsOf: URL(string: "data:text/plain,abcde")!)!
        let item = TestExtensionItem(mockAttachments: [attachment])
        presenter.load(items: [item])
        wait(for: [expectation], timeout: 0.5)
        presenter.submit(comment: nil)
        XCTAssertTrue(uploadManager.cancelWasCalled)
        XCTAssertTrue(uploadManager.uploadWasCalled)
    }

    var onUpdate: () -> Void = {}
    func update() {
        onUpdate()
    }
}
