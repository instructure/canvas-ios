//
// Copyright (C) 2018-present Instructure, Inc.
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

import UIKit
import XCTest
@testable import Core

class RichContentEditorPresenterTests: CoreTestCase {
    var viewError: Error?
    var viewImage: (url: URL, placeholder: String)?
    var viewMedia: URL?
    var viewFiles: [File]?

    lazy var presenter = RichContentEditorPresenter(view: self, uploadTo: .myFiles)

    func testUpdate() {
        let file = File.make(batchID: presenter.batchID, removeURL: true)
        presenter.update()
        XCTAssertEqual(viewFiles, [file])
        XCTAssertEqual(databaseClient.fetch() as [File], [file])
    }

    func testUpdateDeletesComplete() {
        File.make(from: .make(id: "2", media_entry_id: "2"), batchID: presenter.batchID, removeURL: true)
        File.make(from: .make(id: "3", url: URL(string: "/")!), batchID: presenter.batchID)
        File.make(batchID: presenter.batchID, removeURL: true, uploadError: "doh")
        presenter.update()
        XCTAssertEqual((databaseClient.fetch() as [File]).count, 0)
    }

    func testImagePickerControllerNoData() {
        presenter.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [:])
        XCTAssertNotNil(viewError)
    }

    func testImagePickerControllerOriginal() {
        presenter.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [
            .originalImage: UIImage.icon(.cameraSolid),
        ])
        XCTAssertNotNil(viewImage)
    }

    func testImagePickerControllerEdited() {
        presenter.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [
            .editedImage: UIImage.icon(.cameraSolid),
        ])
        XCTAssertNotNil(viewImage)
    }

    func testImagePickerControllerMediaURL() {
        presenter.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [
            .mediaURL: URL(string: "/")!,
        ])
        XCTAssertNotNil(viewMedia)
    }

    func testRetry() {
        presenter.retry(URL(string: "/file.jpg")!)
        XCTAssertNil(viewImage)
        presenter.retry(URL(string: "/file.m4v")!)
        XCTAssertNil(viewMedia)
    }
}

extension RichContentEditorPresenterTests: RichContentEditorViewProtocol {
    func showError(_ error: Error) {
        viewError = error
    }

    func insertImagePlaceholder(_ url: URL, placeholder: String) {
        viewImage = (url: url, placeholder: placeholder)
    }

    func insertVideoPlaceholder(_ url: URL) {
        viewMedia = url
    }

    func updateUploadProgress(of files: [File]) {
        viewFiles = files
    }
}

class MockPicker: UIImagePickerController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        completion?()
    }
}
