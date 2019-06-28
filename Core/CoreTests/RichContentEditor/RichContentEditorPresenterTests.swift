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
import CoreData

class RichContentEditorPresenterTests: CoreTestCase {
    var viewError: Error?
    var viewImage: (url: URL, placeholder: String)?
    var viewMedia: URL?
    var viewFiles: [File]?
    let filesContext = NSPersistentContainer.shared.viewContext

    lazy var presenter = RichContentEditorPresenter(view: self, uploadTo: .myFiles)

    func testUpdate() throws {
        let file = File.make(batchID: presenter.batchID, removeURL: true, session: currentSession, in: filesContext)
        presenter.update()
        XCTAssertEqual(viewFiles, [file])
        XCTAssertEqual(filesContext.fetch() as [File], [file])
    }

    func testUpdateDeletesComplete() {
        File.make(from: .make(id: "2", media_entry_id: "2"), batchID: presenter.batchID, removeURL: true, session: currentSession, in: filesContext)
        File.make(from: .make(id: "3", url: URL(string: "/")!), batchID: presenter.batchID, session: currentSession, in: filesContext)
        File.make(batchID: presenter.batchID, removeURL: true, uploadError: "doh", session: currentSession, in: filesContext)
        presenter.update()
        XCTAssertEqual((filesContext.fetch() as [File]).count, 0)
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
        let url = URL.temporaryDirectory.appendingPathComponent("audio.mp3")
        FileManager.default.createFile(atPath: url.path, contents: "this is some audio".data(using: .utf8), attributes: nil)
        presenter.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [
            .mediaURL: url,
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
