//
// Copyright (C) 2017-present Instructure, Inc.
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

import UIKit
import ReactiveSwift
import Result

public protocol DocumentMenuController: UIDocumentMenuDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var documentMenuViewModel: DocumentMenuViewModelType { get }

    func presentDocumentMenuViewController(_ documentMenu: UIDocumentMenuViewController)
    func documentMenuFinished(error: NSError)
    func documentMenuFinished(uploadable: Uploadable)
}

extension DocumentMenuController where Self: UIViewController {
    public func bindDocumentMenuViewModel() {
        documentMenuViewModel.outputs.showDocumentMenu
            .observe(on: UIScheduler())
            .observeValues { [weak self] options, fileTypes in
                self?.presentDocumentMenu(fileTypes: fileTypes, options: options)
            }

        documentMenuViewModel.outputs.showImagePicker
            .observe(on: UIScheduler())
            .observeValues { [weak self] sourceType, mediaTypes in
                self?.presentImagePickerController(sourceType: sourceType, mediaTypes: mediaTypes)
            }

        documentMenuViewModel.outputs.showAudioRecorder
            .observe(on: UIScheduler())
            .observeValues { [weak self] buttonTitle in
                self?.presentAudioRecorder(completeButtonTitle: buttonTitle)
            }

        documentMenuViewModel.outputs.showDocumentPicker
            .observe(on: UIScheduler())
            .observeValues { [weak self] picker in
                self?.presentDocumentPicker(picker)
            }

        documentMenuViewModel.outputs.uploadable
            .observe(on: UIScheduler())
            .observeValues { [weak self] uploadable in
                self?.documentMenuFinished(uploadable: uploadable)
            }

        documentMenuViewModel.outputs.errors
            .observeValues { [weak self] error in
                self?.documentMenuFinished(error: error)
            }
    }

    public func presentDocumentMenu(fileTypes: [String], options: [DocumentOption]) {
        let docsMenu = UIDocumentMenuViewController(documentTypes: fileTypes, in: .import)
        docsMenu.delegate = self

        for option in options {
            docsMenu.addOption(withTitle: option.title, image: option.icon, order: .first) { [weak self] in
                self?.documentMenuViewModel.inputs.tappedDocumentOption(option)
            }
        }

        self.presentDocumentMenuViewController(docsMenu)
    }

    public func presentDocumentMenuViewController(_ documentMenu: UIDocumentMenuViewController) {
        present(documentMenu, animated: true, completion: nil)
    }

    public func presentImagePickerController(sourceType: UIImagePickerControllerSourceType, mediaTypes: [String]) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes

        present(picker, animated: true, completion: nil)
    }

    public func presentAudioRecorder(completeButtonTitle: String) {
        let recorder = AudioRecorderViewController.new(completeButtonTitle: completeButtonTitle)
        recorder.didFinishRecordingAudioFile = { [weak self] file in
            recorder.dismiss(animated: true) {
                self?.documentMenuViewModel.inputs.recorded(audioFile: file)
            }
        }
        recorder.cancelButtonTapped = {
            recorder.dismiss(animated: true, completion: nil)
        }

        present(recorder, animated: true, completion: nil)
    }

    private func presentDocumentPicker(_ controller: UIDocumentPickerViewController) {
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        controller.dismiss(animated: true) {
            self.documentMenuViewModel.inputs.pickedDocument(at: url)
        }
    }
}
