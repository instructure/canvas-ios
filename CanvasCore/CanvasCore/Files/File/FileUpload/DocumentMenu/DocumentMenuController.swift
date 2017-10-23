//
// Copyright (C) 2016-present Instructure, Inc.
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
