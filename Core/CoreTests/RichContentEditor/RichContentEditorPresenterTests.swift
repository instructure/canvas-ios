//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit
import XCTest
@testable import Core
import CoreData

class RichContentEditorPresenterTests: CoreTestCase {
    var viewError: Error?
    var viewImage: (url: URL, placeholder: String)?
    var viewMedia: URL?
    var viewFiles: [File]?
    var onLoadHTML: (() -> Void)?
    let filesContext = NSPersistentContainer.shared.viewContext

    lazy var presenter = RichContentEditorPresenter(view: self, context: ContextModel(.course, id: "1"), uploadTo: .myFiles)

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

    func testLoadHTML() {
        let expectation = XCTestExpectation(description: "loads html")
        onLoadHTML = { expectation.fulfill() }
        FeatureFlag.make(context: presenter.context, enabled: true)
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
    }
}

extension RichContentEditorPresenterTests: RichContentEditorViewProtocol {
    func loadHTML() {
        onLoadHTML?()
    }

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
