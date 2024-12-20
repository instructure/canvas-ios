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
@testable import Core

class NSErrorExtensionsTests: CoreTestCase {
    func testInternalError() {
        XCTAssertEqual(NSError.internalError(), NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: "Internal Error"]))
    }

    func testInstructureError() {
        XCTAssertEqual(NSError.instructureError("doh!"), NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: "doh!"]))
    }

    func testShouldRecordInCrashlytics() {
        XCTAssertFalse(NSError(domain: NSCocoaErrorDomain, code: 13).shouldRecordInCrashlytics)
        XCTAssertFalse(NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet).shouldRecordInCrashlytics)
        XCTAssertFalse(NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut).shouldRecordInCrashlytics)
        XCTAssertFalse(NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost).shouldRecordInCrashlytics)
        XCTAssertFalse(NSError(domain: NSURLErrorDomain, code: NSURLErrorDataNotAllowed).shouldRecordInCrashlytics)

        XCTAssertTrue(NSError(domain: NSCocoaErrorDomain, code: 0).shouldRecordInCrashlytics)
        XCTAssertTrue(NSError(domain: NSURLErrorDomain, code: 0).shouldRecordInCrashlytics)
        XCTAssertTrue(NSError.internalError().shouldRecordInCrashlytics)
    }

    func testShowAlert() {
        let view = UIViewController()
        var error = NSError(domain: NSCocoaErrorDomain, code: 13)
        error.showAlert(from: nil)
        XCTAssertNil(router.presented)

        error.showAlert(from: view)
        var alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Disk Error")
        XCTAssertEqual(alert?.message, "Your device is out of storage space. Please free up space and try again.")
        XCTAssertEqual(alert?.actions.count, 1)

        error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        error.showAlert(from: view)
        alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Network Error")
        XCTAssertEqual(alert?.message, error.localizedDescription)
        XCTAssertEqual(alert?.actions.count, 2)

        error = NSError(domain: "com.instructure.canvas", code: 90211)
        error.showAlert(from: view)
        alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Notification Error")
        XCTAssertEqual(alert?.message, "There was a problem registering your device for push notifications.")
        XCTAssertEqual(alert?.actions.count, 2)

        error = NSError.internalError()
        error.showAlert(from: view)
        alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Unknown Error")
        XCTAssertEqual(alert?.message, error.localizedDescription)
        XCTAssertEqual(alert?.actions.count, 2)

        error = NSError(domain: "", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "description",
            NSLocalizedFailureReasonErrorKey: "reason"
        ])
        error.showAlert(from: view)
        alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Unknown Error")
        XCTAssertEqual(alert?.message, "description\n\nreason")
        XCTAssertEqual(alert?.actions.count, 2)

        let action = alert?.actions.first as? AlertAction
        action?.handler?(action!)
        XCTAssert(router.presented is ErrorReportViewController)
    }
}
