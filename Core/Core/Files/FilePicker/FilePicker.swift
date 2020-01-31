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

import Foundation
import UIKit

public protocol FilePickerDelegate: ErrorViewController {
    func filePicker(didPick url: URL)
    func filePicker(didRetry file: File)
}

public class FilePicker: NSObject {
    let env = AppEnvironment.shared
    public weak var delegate: FilePickerDelegate?

    public init(delegate: FilePickerDelegate?) {
        self.delegate = delegate
    }

    public func pick(from: UIViewController) {
        let sheet = BottomSheetPickerViewController.create()

        sheet.addAction(image: .icon(.audio), title: NSLocalizedString("Record Audio", bundle: .core, comment: "")) { [weak self] in
            let controller = AudioRecorderViewController.create()
            controller.delegate = self
            controller.view.backgroundColor = UIColor.named(.backgroundLightest)
            controller.modalPresentationStyle = .formSheet
            self?.env.router.show(controller, from: from, options: .modal())
        }

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(image: .icon(.cameraLine), title: NSLocalizedString("Use Camera", bundle: .core, comment: "")) { [weak self] in
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .camera
                controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
                self?.env.router.show(controller, from: from, options: .modal())
            }
        }

        sheet.addAction(image: .icon(.paperclip), title: NSLocalizedString("Upload File", bundle: .core, comment: "")) { [weak self] in
            let controller = UIDocumentPickerViewController(documentTypes: [UTI.any.rawValue], in: .import)
            controller.delegate = self
            self?.env.router.show(controller, from: from, options: .modal())
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            sheet.addAction(image: .icon(.image), title: NSLocalizedString("Photo Library", bundle: .core, comment: "")) { [weak self] in
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .photoLibrary
                controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
                controller.modalPresentationStyle = .overCurrentContext
                self?.env.router.show(controller, from: from, options: .modal())
            }
        }

        env.router.show(sheet, from: from, options: .modal())
    }

    public func showOptions(for file: File, from: UIViewController) {
        let sheet = BottomSheetPickerViewController.create()

        if file.uploadError != nil {
            sheet.addAction(image: .icon(.refresh), title: NSLocalizedString("Retry", bundle: .core, comment: "")) { [weak self] in
                self?.delegate?.filePicker(didRetry: file)
            }
        }

        sheet.addAction(image: .icon(.trash), title: NSLocalizedString("Delete", bundle: .core, comment: "")) { [weak self] in
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
                    .temporaryDirectory
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
        for url in urls { delegate?.filePicker(didPick: url) }
    }
}
