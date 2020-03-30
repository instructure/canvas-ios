//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import ReactiveSwift

public protocol DocumentMenuController: UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var documentMenuViewModel: DocumentMenuViewModelType { get }
    var menuSourceView: UIView { get }

    func presentDocumentMenuViewController(_ documentMenu: UIDocumentPickerViewController)
    func documentMenuFinished(error: NSError)
    func documentMenuFinished(uploadable: Uploadable)
    func documentMenuWasCancelled()
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for option in options {
            let a = UIAlertAction(title: option.title, style: .default) {  [weak self] action in
                self?.documentMenuViewModel.inputs.tappedDocumentOption(option)
            }
            a.setValue(option.icon, forKey: "image")
            alert.addAction(a)
        }

        let icloudBrowser = UIAlertAction(title: NSLocalizedString("Browse", comment: ""), style: .default) {  [weak self] action in
            let docPicker = UIDocumentPickerViewController(documentTypes: fileTypes, in: .import)
            self?.documentMenuViewModel.inputs.tappedDocumentPicker(docPicker)
        }

        alert.addAction(icloudBrowser)

        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { [weak self] action in
            self?.documentMenuWasCancelled()
        }
        alert.addAction(cancel)

        alert.popoverPresentationController?.sourceView = menuSourceView
        alert.popoverPresentationController?.sourceRect = menuSourceView.bounds

        present(alert, animated: true, completion: nil)
    }

    public func presentDocumentMenuViewController(_ documentMenu: UIDocumentPickerViewController) {
        present(documentMenu, animated: true, completion: nil)
    }

    public func presentImagePickerController(sourceType: UIImagePickerController.SourceType, mediaTypes: [String]) {
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

    public func documentMenuWasCancelled() {}
}
