//
//  NewSubmissionViewModelShim.swift
//  Assignments
//
//  Created by Nathan Armstrong on 1/23/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import ReactiveSwift
import Result
import TooLegit
import SoLazy
import FileKit
import SoPersistent
import SoPretty

@objc public protocol NewSubmissionViewModelShimProtocol: class {
    func newSubmissionViewModel(_ newSubmissionViewModel: NewSubmissionViewModel, wantsToPresentViewController viewController: UIViewController, completion: ((Void) -> Void)?)
    func newSubmissionViewModel(_ newSubmissionViewModel: NewSubmissionViewModel, wantsToPresentTurnInPrompt alertController: UIAlertController, completion: ((Void) -> Void)?)
    func newSubmissionViewModel(_ newSubmissionViewModel: NewSubmissionViewModel, createdSubmission submission: Submission)
    func newSubmissionViewModel(_ newSubmissionViewModel: NewSubmissionViewModel, failedWith error: String)
}

public class NewSubmissionViewModelShim: NewSubmissionViewModel {
    public weak var delegate: NewSubmissionViewModelShimProtocol?

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
                                 bundle: Bundle(identifier: "com.instructure.AssignmentKit")!,
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
                                     bundle: Bundle(identifier: "com.instructure.AssignmentKit")!,
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
