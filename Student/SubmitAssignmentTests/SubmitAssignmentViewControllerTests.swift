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

import Foundation
import XCTest
@testable import Core
import Social
@testable import TestsFoundation

class SubmitAssignmentViewControllerTests: SubmitAssignmentTestCase {
    var viewController: SubmitAssignmentViewController!

    var configurationItems: [SLComposeSheetConfigurationItem] {
        return viewController.configurationItems() as! [SLComposeSheetConfigurationItem]
    }

    override func setUp() {
        super.setUp()
        LoginSession.add(.make())
        env.userDefaults?.reset()
        viewController = SubmitAssignmentViewController()
        viewController.uploadManager = uploadManager
    }

    func testLayout() {
        env.userDefaults?.submitAssignmentCourseID = "1"
        env.userDefaults?.submitAssignmentID = "1"
        api.mock(GetCourseRequest(courseID: "1", include: []), value: .make(id: "1", name: "C1"))
        api.mock(GetAssignmentRequest(courseID: "1", assignmentID: "1", include: []), value: .make(
            id: "1",
            name: "A1",
            submission_types: [.online_upload])
        )
        let fileURL = URL.temporaryDirectory.appendingPathComponent("loadFileURL.txt", isDirectory: false)
        try! "test".write(to: fileURL, atomically: false, encoding: .utf8)
        viewController.view.layoutIfNeeded()
        viewController.env.database = database
        viewController.env.api = URLSessionAPI(urlSession: MockURLSession())
        viewController.presentationAnimationDidFinish()
        XCTAssertEqual(configurationItems.count, 2)
        XCTAssertEqual(configurationItems[0].title, "Course")
        XCTAssertEqual(configurationItems[0].value, "C1")
        XCTAssertFalse(configurationItems[0].valuePending)
        XCTAssertNoThrow(configurationItems[0].tapHandler)
        XCTAssertEqual(configurationItems[1].title, "Assignment")
        XCTAssertEqual(configurationItems[1].value, "A1")
        XCTAssertFalse(configurationItems[1].valuePending)
        XCTAssertNoThrow(configurationItems[1].tapHandler)
        let data = NSItemProvider(item: Data() as NSSecureCoding, typeIdentifier: UTI.any.rawValue)
        let file = NSItemProvider(item: fileURL as NSSecureCoding, typeIdentifier: UTI.fileURL.rawValue)
        let image = NSItemProvider(item: UIImage.icon(.addImageLine), typeIdentifier: UTI.image.rawValue)
        let item = TestExtensionItem(mockAttachments: [data, file, image])
        viewController.load(items: [item])
        drainMainQueue()
        XCTAssertTrue(viewController.isContentValid())
        let expectation = XCTestExpectation(description: "submit")
        viewController.submit(comment: nil, callback: expectation.fulfill)
        wait(for: [expectation], timeout: 10)
        XCTAssertTrue(uploadManager.addWasCalled)
        XCTAssertTrue(uploadManager.uploadWasCalled)
    }
}

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
