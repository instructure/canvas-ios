//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class AttachmentCopyServiceTests: CoreTestCase {

    func testFailureStateOnNoFiles() {
        let stateUpdateExpectation = expectation(description: "State updated")
        stateUpdateExpectation.expectedFulfillmentCount = 2 // loading, failure
        var receivedState: AttachmentCopyService.State?

        let testee = AttachmentCopyService(extensionContext: nil)
        let subscription = testee.state.sink { state in
            receivedState = state
            stateUpdateExpectation.fulfill()
        }

        testee.startCopying()
        wait(for: [stateUpdateExpectation], timeout: 0.5)
        subscription.cancel()

        guard case .completed(let result) = receivedState, case .failure(let error) = result else {
            XCTFail("Invalid state \(String(describing: receivedState)) received.")
            return
        }

        XCTAssertEqual(error.localizedDescription, String(localized: "No supported files to submit", bundle: .core))
    }

    // Upload fails in this test because AttachmentCopyService can't create the destination url for the CoreTester bundle
    func testFailureStateOnInvalidAppBundle() {
        let stateUpdateExpectation = expectation(description: "State updated")
        stateUpdateExpectation.expectedFulfillmentCount = 2 // loading, failure
        var receivedState: AttachmentCopyService.State?

        let data = NSItemProvider(item: Data() as NSSecureCoding, typeIdentifier: UTI.text.rawValue)
        let testee = AttachmentCopyService(extensionContext: TestExtensionContext(mockInputItem: TestExtensionItem(mockAttachments: [data])))

        let subscription = testee.state.sink { state in
            receivedState = state
            stateUpdateExpectation.fulfill()
        }

        testee.startCopying()
        wait(for: [stateUpdateExpectation], timeout: 0.5)
        subscription.cancel()

        guard case .completed(let result) = receivedState, case .failure(let error) = result else {
            XCTFail("Invalid state \(String(describing: receivedState)) received.")
            return
        }

        XCTAssertEqual(error.localizedDescription, String(localized: "Internal Error", bundle: .core))
    }
}

class TestExtensionItem: NSExtensionItem {
    private var mocks: [NSItemProvider]?

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

class TestExtensionContext: NSExtensionContext {
    private var mocks: [Any]

    override var inputItems: [Any] {
        get { return mocks }
        set { mocks = newValue }
    }

    init(mockInputItems: [NSExtensionItem]) {
        self.mocks = mockInputItems
    }

    convenience init(mockInputItem: NSExtensionItem) {
        self.init(mockInputItems: [mockInputItem])
    }
}
