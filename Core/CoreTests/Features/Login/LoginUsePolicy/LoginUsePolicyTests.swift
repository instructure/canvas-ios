//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import TestsFoundation

class LoginUsePolicyTests: CoreTestCase {

    func testCheckAcceptablePolicy() {
        let controller = UITabBarController()
        controller.viewDidLoad()
        controller.view.layoutIfNeeded()
        let env = AppEnvironment.shared
        api.mock(GetWebSessionRequest(to: env.api.baseURL.appendingPathComponent("users/self")),
                 value: GetWebSessionRequest.Response(session_url: URL(string: "https://canvas.instructure.com/")!,
                                                      requires_terms_acceptance: true))
        LoginUsePolicy.checkAcceptablePolicy(from: controller)
        wait(for: [router.showExpectation], timeout: 5)
        XCTAssert(router.presented is CoreHostingController<LoginUsePolicyView>)
    }

    func testCheckAcceptablePolicyEmptyResponse() {
        let controller = UITabBarController()
        controller.viewDidLoad()
        controller.view.layoutIfNeeded()
        let env = AppEnvironment.shared
        api.mock(GetWebSessionRequest(to: env.api.baseURL.appendingPathComponent("users/self")),
                 value: nil)
        LoginUsePolicy.checkAcceptablePolicy(from: controller) {
            XCTFail()
        }
        XCTAssertEqual(router.last, nil)
    }

    func testAcceptUsePolicy() {
        let successExpectation = XCTestExpectation(description: "API call should succeed")
        api.mock(PutUserAcceptedTermsRequest(hasAccepted: true), value: .makeUser(role: "Student", id: 123))
        LoginUsePolicy.acceptUsePolicy { result in
            switch result {
            case let .failure(error):
                XCTFail(error.localizedDescription)
            case .success(()):
                successExpectation.fulfill()
            }
        }
        let expectedError = NSError.internalError()
        api.mock(PutUserAcceptedTermsRequest(hasAccepted: true), value: nil, error: expectedError)
        LoginUsePolicy.acceptUsePolicy { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as NSError, expectedError)
            case .success(()):
                XCTFail()
            }
        }
    }
}
