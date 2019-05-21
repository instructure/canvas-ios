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
@testable import Core
import TestsFoundation

class FilePickerPresenterTests: CoreTestCase, FilePickerViewProtocol {
    // MARK: - FilePickerViewProtocol
    var didUpdate = XCTestExpectation(description: "did update")
    func update() {
        didUpdate.fulfill()
    }

    func showError(_ error: Error) {}

    let batchID = "1"
    lazy var presenter = FilePickerPresenter(environment: environment, batchID: batchID)

    override func setUp() {
        super.setUp()
        presenter.view = self
        didUpdate.assertForOverFulfill = false
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        wait(for: [didUpdate], timeout: 0.1)
    }

    func testAddURL() {
        let url = URL(string: "data:audio/x-aac,")!
        presenter.viewIsReady()
        wait(for: [didUpdate], timeout: 0.1)
        didUpdate = self.expectation(description: "did update again")
        didUpdate.assertForOverFulfill = false
        presenter.add(url: url)
        wait(for: [didUpdate], timeout: 0.1)
    }
}
