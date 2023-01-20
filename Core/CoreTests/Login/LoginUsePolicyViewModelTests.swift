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

class LoginUsePolicyViewModelTests: CoreTestCase {

    func testAcceptUsePolicy() {
        let testee = LoginUsePolicyViewModel(accepted: {}, cancelled: {})
        let successExpectation = XCTestExpectation(description: "API call should succeed")
        api.mock(PutUserAcceptedTermsRequest(hasAccepted: true), value: .makeUser(role: "Student", id: 123))
        testee.acceptUsePolicy { result in
            switch result {
            case let .failure(error):
                XCTFail(error.localizedDescription)
            case .success(()):
                successExpectation.fulfill()
            }
        }
        let expectedError = NSError.internalError()
        api.mock(PutUserAcceptedTermsRequest(hasAccepted: true), value: nil, error: expectedError)
        testee.acceptUsePolicy { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as NSError, expectedError)
            case .success(()):
                XCTFail()
            }
        }
    }

    func testSubmitAcceptance() {
        let successExpectation = XCTestExpectation(description: "accepted callback should be called")
        let testee = LoginUsePolicyViewModel {
            successExpectation.fulfill()
        } cancelled: {
            XCTFail()
        }
        api.mock(PutUserAcceptedTermsRequest(hasAccepted: true), value: .makeUser(role: "Student", id: 123))
        testee.submitAcceptance()
    }

    func testCancelAcceptance() {
        let cancelExpectation = XCTestExpectation(description: "accepted callback should be called")
        let testee = LoginUsePolicyViewModel {
            XCTFail()
        } cancelled: {
            cancelExpectation.fulfill()
        }
        testee.cancelAcceptance()
    }
}
