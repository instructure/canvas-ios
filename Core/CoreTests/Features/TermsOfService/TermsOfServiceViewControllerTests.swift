//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class TermsOfServiceViewControllerTests: CoreTestCase {
    lazy var controller = TermsOfServiceViewController()

    func testSuccess() {
        api.mock(GetAccountTermsOfServiceRequest(), value: .make())
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.title, "Terms of Use")
        XCTAssertEqual(controller.webView.url?.absoluteString, "https://canvas.instructure.com/")
    }

    func testFailure() {
        api.mock(GetAccountTermsOfServiceRequest(), error: NSError.internalError())
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.title, "Terms of Use")
        let errorLabel = controller.view.subviews.last as? UILabel
        XCTAssertEqual(errorLabel?.text, "There was a problem retrieving the Terms of Use.")
    }
}
