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

import Foundation
@testable import Student
import UIKit
@testable import Core

class FilePickerView: FilePickerViewProtocol {
    var presenter: FilePickerPresenterProtocol?
    var navigationController: UINavigationController?
    var presentCameraCallCount = 0
    var presentLibraryCallCount = 0
    var files: Store<LocalUseCase<File>>?
    var sources: [FilePickerSource]?
    var presentedDocumentTypes: [String]?
    var error: Error?
    var progress: Float = 0
    var toolbarItems: [UIBarButtonItem]?
    var navigationItems: (left: [UIBarButtonItem], right: [UIBarButtonItem])?
    var dismissed: Bool = false
    var onUpdate: (() -> Void)?
    var bytesSent: Int?
    var expectedToSend: Int?
    var onDismissed: (() -> Void)?
    var onError: (() -> Void)?

    func presentCamera() {
        presentCameraCallCount += 1
    }

    func presentLibrary() {
        presentLibraryCallCount += 1
    }

    func presentDocumentPicker(documentTypes: [String]) {
        presentedDocumentTypes = documentTypes
    }

    func showError(_ error: Error) {
        self.error = error
        onError?()
    }

    func showError(message: String) {
        showError(NSError.instructureError(message))
    }

    func update() {
        self.files = presenter?.files
        self.sources = presenter?.sources
        onUpdate?()
    }

    func updateTransferProgress(_ progress: Float, sent: Int, expectedToSend: Int) {
        self.progress = progress
        self.bytesSent = sent
        self.expectedToSend = expectedToSend
    }

    func updateTransferProgress(_ progress: Float) {
        self.progress = progress
    }

    func updateToolbar(items: [UIBarButtonItem]) {
        toolbarItems = items
    }

    func updateNavigationItems(left: [UIBarButtonItem], right: [UIBarButtonItem]) {
        navigationItems = (left: left, right: right)
    }

    func dismiss() {
        dismissed = true
        onDismissed?()
    }
}
