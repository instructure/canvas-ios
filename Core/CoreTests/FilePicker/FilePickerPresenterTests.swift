//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
