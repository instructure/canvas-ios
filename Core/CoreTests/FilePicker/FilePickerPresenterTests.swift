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
    var didReachMaxFileCountExpectation = XCTestExpectation(description: "expectation")

    override func setUp() {
        super.setUp()
        presenter.view = self
        didUpdate.assertForOverFulfill = false
        didReachMaxFileCountExpectation = XCTestExpectation(description: "expectation")
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        wait(for: [didUpdate], timeout: 0.1)
    }

    func testAddURL() {
        let url = URL.temporaryDirectory.appendingPathComponent("FilePickerPresenterTests-testAddURL.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8), attributes: nil)
        presenter.viewIsReady()
        wait(for: [didUpdate], timeout: 0.1)
        didUpdate = self.expectation(description: "did update again")
        didUpdate.assertForOverFulfill = false
        presenter.add(url: url)
        wait(for: [didUpdate], timeout: 0.1)
    }

    func testMaxFileCount() {
        let url = URL.temporaryDirectory.appendingPathComponent("FilePickerPresenterTests-testAddURL.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8), attributes: nil)
        presenter.maxFileCount = 1
        presenter.add(url: url)
        wait(for: [didReachMaxFileCountExpectation], timeout: 0.4)
        XCTAssertTrue(presenter.files.count == 1)
    }

    func didReachMaxFileCount() {
        didReachMaxFileCountExpectation.fulfill()
    }

}
