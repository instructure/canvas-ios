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

import ReactiveSwift
import Result



@objc public protocol NewSubmissionViewModelShimProtocol: class {
    func newSubmissionViewModel(_ newSubmissionViewModel: NewSubmissionViewModel, wantsToPresentViewController viewController: UIViewController, completion: (() -> Void)?)
    func newSubmissionViewModel(_ newSubmissionViewModel: NewSubmissionViewModel, wantsToPresentTurnInPrompt alertController: UIAlertController, completion: (() -> Void)?)
    func newSubmissionViewModel(_ newSubmissionViewModel: NewSubmissionViewModel, createdSubmission submission: Submission)
    func newSubmissionViewModel(_ newSubmissionViewModel: NewSubmissionViewModel, failedWith error: String)
}

public class NewSubmissionViewModelShim: NewSubmissionViewModel {
    public weak var delegate: NewSubmissionViewModelShimProtocol?
    fileprivate let documentMenuViewModel: DocumentMenuViewModelType = DocumentMenuViewModel()

    override init() {
        super.init()

        showSubmissionTypesSheet
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.presentSubmissionsTypesSheet($0)
            }

        showFileUploads
            .observe(on: UIScheduler())
            .observeValues { [weak self] session, courseID, batch in
                self?.presentFileUploads(session: session, courseID: courseID, batch: batch)
            }

        submission
            .observe(on: UIScheduler())
            .observeValues { [weak self] submission in
                if let me = self {
                    self?.delegate?.newSubmissionViewModel(me, createdSubmission: submission)
                }
            }

        showError
            .observe(on: UIScheduler())
            .observeValues { [weak self] error in
                if let me = self {
                    self?.delegate?.newSubmissionViewModel(me, failedWith: error)
                }
            }

        showTextEntry
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.presentTextEntry()
            }

        showURLPicker
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.presentURLPicker()
            }

        showDocumentMenu
            .observe(on: UIScheduler())
            .observeValues { [weak self]  in
                self?.documentMenuViewModel.inputs.configureWith(fileTypes: $0)
                self?.documentMenuViewModel.inputs.showDocumentMenuButtonTapped()
            }

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
                self?.inputs.selected(uploadable: uploadable)
            }

        documentMenuViewModel.outputs.errors
            .observeValues { [weak self] error in
                guard let me = self else { return }
                self?.delegate?.newSubmissionViewModel(me, failedWith: error.localizedDescription)
            }
    }

    private struct AssignmentProtocolShim: AssignmentProtocol {
        let id: String
        let courseID: String
        let submissionTypes: SubmissionTypes
        let allowedExtensions: [String]?
        let groupSetID: String?
    }

    public func configureWith(session: Session, id: String, courseID: String, submissionTypes: [String], allowedExtensions: [String]?, groupSetID: String?) {
        let assignment = AssignmentProtocolShim(
            id: id,
            courseID: courseID,
            submissionTypes: SubmissionTypes.fromStrings(submissionTypes),
            allowedExtensions: allowedExtensions,
            groupSetID: groupSetID
        )
        configureWith(session: session, assignment: assignment)
    }

    private func presentSubmissionsTypesSheet(_ submissionTypes: [SubmissionType]) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelTitle = NSLocalizedString("Cancel",
                                 tableName: "Localizable",
                                 bundle: .core,
                                 value: "",
                                 comment: "Cancel submission option")
        actionSheet.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))

        for submissionType in submissionTypes {
            actionSheet.addAction(UIAlertAction(title: submissionType.title, style: .default) { [weak self] _ in
                self?.inputs.submissionTypeButtonTapped(submissionType)
            })
        }

        self.delegate?.newSubmissionViewModel(self, wantsToPresentTurnInPrompt: actionSheet, completion: nil)
    }

    private func presentFileUploads(session: Session, courseID: String, batch: FileUploadBatch) {
        let fileUploads = FileUploadsViewController.configuredWith(session: session, batch: batch)
        fileUploads.delegate = self
        let nav = UINavigationController(rootViewController: fileUploads)
        self.delegate?.newSubmissionViewModel(self, wantsToPresentViewController: nav) {
            fileUploads.doneButton.title = NSLocalizedString("Submit",
                                     tableName: "Localizable",
                                     bundle: .core,
                                     value: "",
                                     comment: "Submit assignment button")
            fileUploads.addFile()
        }
    }

    private func presentTextEntry() {
        let textEntry = TextEntrySubmissionViewController(style: .plain)
        textEntry.didFinishEnteringText = { [weak self] text in
            if let text = text {
                self?.inputs.submit(newSubmission: .text(text))
            }
        }
        let nav = SmallModalNavigationController(rootViewController: textEntry)
        nav.preferredContentSize = CGSize(width: 300, height: 240)
        self.delegate?.newSubmissionViewModel(self, wantsToPresentViewController: nav, completion: nil)
    }

    private func presentURLPicker() {
        let browser = BrowserViewController()
        browser.didSelectURLForSubmission = { [weak self] url in
            self?.inputs.submit(newSubmission: .url(url))
        }

        let nav = UINavigationController(rootViewController: browser)
        self.delegate?.newSubmissionViewModel(self, wantsToPresentViewController: nav, completion: nil)
    }

    private func presentDocumentMenu(fileTypes: [String], options: [DocumentOption]) {
        let docsMenu = UIDocumentMenuViewController(documentTypes: fileTypes, in: .import)
        docsMenu.delegate = self

        for option in options {
            docsMenu.addOption(withTitle: option.title, image: option.icon, order: .first) { [weak self] in
                self?.documentMenuViewModel.inputs.tappedDocumentOption(option)
            }
        }

        self.delegate?.newSubmissionViewModel(self, wantsToPresentViewController: docsMenu, completion: nil)
    }

    private func presentImagePickerController(sourceType: UIImagePickerControllerSourceType, mediaTypes: [String]) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes

        self.delegate?.newSubmissionViewModel(self, wantsToPresentViewController: picker, completion: nil)
    }

    private func presentAudioRecorder(completeButtonTitle: String) {
        let recorder = AudioRecorderViewController.new(completeButtonTitle: completeButtonTitle)
        recorder.didFinishRecordingAudioFile = { [weak self] file in
            self?.documentMenuViewModel.inputs.recorded(audioFile: file)
        }
        recorder.cancelButtonTapped = {
            recorder.dismiss(animated: true, completion: nil)
        }

        self.delegate?.newSubmissionViewModel(self, wantsToPresentViewController: recorder, completion: nil)
    }

    private func presentDocumentPicker(_ controller: UIDocumentPickerViewController) {
        controller.delegate = self
        self.delegate?.newSubmissionViewModel(self, wantsToPresentViewController: controller, completion: nil)
    }
}

extension NewSubmissionViewModelShim: FileUploadsViewControllerDelegate {
    public func fileUploadsViewControllerDidCancel(_ viewController: FileUploadsViewController) {
        viewController.dismiss(animated: true)
    }

    public func fileUploadsViewController(_ viewController: FileUploadsViewController, uploaded files: [File]) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.inputs.submit(newSubmission: .fileUpload(files))
        }
    }
}

extension NewSubmissionViewModelShim: UIDocumentMenuDelegate {
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        self.documentMenuViewModel.inputs.tappedDocumentPicker(documentPicker)
    }
}

extension NewSubmissionViewModelShim: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        controller.dismiss(animated: true) {
            self.documentMenuViewModel.inputs.pickedDocument(at: url)
        }
    }
}

extension NewSubmissionViewModelShim: UINavigationControllerDelegate {}
extension NewSubmissionViewModelShim: UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            self.documentMenuViewModel.inputs.pickedMedia(with: info)
        }
    }
}
