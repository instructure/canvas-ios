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

import Combine
import UIKit
import UniformTypeIdentifiers

public protocol FilePickerDelegate: ErrorViewController {
    /**
     - parameters:
        - url: The URL pointing to a copy of the picked file. It's the receiver's responsibility to delete this file after it's no longer used.
     */
    func filePicker(didPick url: URL)
    func filePicker(didRetry file: File)
}

public class FilePicker: NSObject {
    let env = AppEnvironment.shared
    public weak var delegate: FilePickerDelegate?
    public var batchAction: ((String) -> Void)?
    public var singleAction: ((Result<URL, Error>) -> Void)?
    private var subscriptions = Set<AnyCancellable>()

    public init(delegate: FilePickerDelegate? = nil) {
        self.delegate = delegate
    }

    public func pick(from: UIViewController) {
        let sheet = BottomSheetPickerViewController.create()

        sheet.addAction(image: .audioLine, title: NSLocalizedString("Record Audio", bundle: .core, comment: "")) { [weak self] in
            let controller = AudioRecorderViewController.create()
            controller.delegate = self
            controller.view.backgroundColor = UIColor.backgroundLightest
            controller.modalPresentationStyle = .formSheet
            self?.env.router.show(controller, from: from, options: .modal())
        }

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(image: .cameraLine, title: NSLocalizedString("Use Camera", bundle: .core, comment: "")) { [weak self] in
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .camera
                controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
                self?.env.router.show(controller, from: from, options: .modal())
            }
        }

        sheet.addAction(image: .paperclipLine, title: NSLocalizedString("Upload File", bundle: .core, comment: "")) { [weak self] in
            // The asCopy: true ensures that file operations leave the original file untouched
            // and we can safely work (annotate for example) on a copy of the original file
            let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
            controller.delegate = self
            self?.env.router.show(controller, from: from, options: .modal())
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            sheet.addAction(image: .imageLine, title: NSLocalizedString("Photo Library", bundle: .core, comment: "")) { [weak self] in
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .photoLibrary
                controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
                self?.env.router.show(controller, from: from, options: .modal())
            }
        }

        env.router.show(sheet, from: from, options: .modal())
    }

    public func showOptions(for file: File, from: UIViewController) {
        let sheet = BottomSheetPickerViewController.create()

        if file.uploadError != nil {
            sheet.addAction(image: .refreshLine, title: NSLocalizedString("Retry", bundle: .core, comment: "")) { [weak self] in
                self?.delegate?.filePicker(didRetry: file)
            }
        }

        sheet.addAction(image: .trashLine, title: NSLocalizedString("Delete", bundle: .core, comment: "")) { [weak self] in
            if let id = file.id {
                self?.env.api.makeRequest(DeleteFileRequest(fileID: id)) { _, _, error in performUIUpdate {
                    if let error = error {
                        self?.delegate?.showError(error)
                    } else {
                        UploadManager.shared.cancel(file: file)
                    }
                } }
            } else {
                UploadManager.shared.cancel(file: file)
            }
        }

        env.router.show(sheet, from: from, options: .modal())
    }
}

extension FilePicker: AudioRecorderDelegate {
    public func cancel(_ controller: AudioRecorderViewController) {
        controller.dismiss(animated: true)
    }

    public func send(_ controller: AudioRecorderViewController, url: URL) {
        controller.dismiss(animated: true) { [weak self] in
            self?.delegate?.filePicker(didPick: url)
        }
    }
}

extension FilePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        do {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                delegate?.filePicker(didPick: try image.write())
            } else if let videoURL = info[.mediaURL] as? URL {
                let destination = URL
                    .Directories
                    .temporary
                    .appendingPathComponent("videos", isDirectory: true)
                    .appendingPathComponent(String(Clock.now.timeIntervalSince1970), isDirectory: true)
                    .appendingPathExtension(videoURL.pathExtension)
                try videoURL.copy(to: destination)
                delegate?.filePicker(didPick: destination)
            }
        } catch {
            delegate?.showError(error)
        }
    }
}

extension FilePicker: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let session = env.currentSession else { return }

        Publishers
            .Sequence<[URL], Never>(sequence: urls)
            .subscribe(on: DispatchQueue.global())
            .compactMap {
                let tempURL = URL
                    .Directories.temporary
                    .appendingPathComponent(UUID.string, isDirectory: true)
                    .appendingPathComponent($0.lastPathComponent, isDirectory: false)
                do {
                    try $0.move(to: tempURL)
                    return tempURL
                } catch {
                    return nil
                }
            }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak delegate] in
                for url in $0 { delegate?.filePicker(didPick: url) }
            }
            .store(in: &subscriptions)
    }
}

extension FilePicker: FilePickerControllerDelegate {
    public func pickAttachments(from: UIViewController, action: @escaping (String) -> Void) {
        batchAction = action
        let uiViewController = FilePickerViewController.create()
        uiViewController.delegate = self
        uiViewController.title = NSLocalizedString("Attachments", comment: "")
        uiViewController.submitButtonTitle = NSLocalizedString("Send", comment: "")
        uiViewController.loadViewIfNeeded()
        uiViewController.emptyView.bodyText = NSLocalizedString("Attach files by tapping an option below.", comment: "")
        env.router.show(uiViewController, from: from, options: .modal(embedInNav: true))
    }

    public func retry(_ controller: FilePickerViewController) {
    }

    public func canSubmit(_ controller: FilePickerViewController) -> Bool {
        return controller.files.isEmpty == false
    }

    public func cancel(_ controller: FilePickerViewController) {
        env.router.dismiss(controller)
    }

    public func submit(_ controller: FilePickerViewController) {
        env.router.dismiss(controller) {
            self.batchAction?(controller.batchID)
        }
    }
}

extension FilePicker: FilePickerDelegate {
    public func pickAttachment(from: UIViewController, action: @escaping (Result<URL, Error>) -> Void) {
        singleAction = action
        delegate = self
        pick(from: from)
    }

    public func showError(_ error: Error) {
        singleAction?(.failure(error))
    }

    public func filePicker(didPick url: URL) {
        singleAction?(.success(url))
    }

    // Should go unused
    public func filePicker(didRetry file: File) {}
    public func showAlert(title: String?, message: String?) {}
}
