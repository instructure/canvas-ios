//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import Core
import Combine

class TextSubmissionViewController: UIViewController, ErrorViewController, RichContentEditorDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    private lazy var submitButton = UIBarButtonItem(
        title: NSLocalizedString("Submit", bundle: .student, comment: ""),
        style: .plain,
        target: self,
        action: #selector(submit)
    )
    private lazy var deleteButton = UIBarButtonItem(
        title: NSLocalizedString("Delete", bundle: .student, comment: ""),
        style: .plain,
        target: self,
        action: #selector(deleteDraftDidTap)
    )

    var assignmentID: String!
    var courseID: String!
    var editor: RichContentEditorViewController!
    let env = AppEnvironment.shared
    var keyboard: KeyboardTransitioning?
    var userID: String!
    var loadDraft: Bool!
    private lazy var assignmentStore = ReactiveStore(
        useCase: GetAssignment(courseID: courseID, assignmentID: assignmentID)
    )
    private var assignment: Assignment?
    private var subscriptions = Set<AnyCancellable>()

    static func create(courseID: String, assignmentID: String, userID: String, loadDraft: Bool) -> TextSubmissionViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.courseID = courseID
        controller.userID = userID
        controller.editor = RichContentEditorViewController.create(context: .course(courseID), uploadTo: .myFiles)
        controller.loadDraft = loadDraft
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = NSLocalizedString("Text Entry", bundle: .student, comment: "")

        navigationController?.navigationBar.useModalStyle()

        submitButton.accessibilityIdentifier = "TextSubmission.submitButton"
        submitButton.isEnabled = false
        deleteButton.isEnabled = false
        navigationItem.rightBarButtonItems = [submitButton, deleteButton]

        addCancelButton(side: .left)

        editor.delegate = self
        editor.placeholder = NSLocalizedString("Write...", bundle: .student, comment: "Text submission editor placeholder")
        editor.a11yLabel = NSLocalizedString("Submission text", bundle: .student, comment: "Text submission editor accessibility label")
        editor.webView.scrollView.layer.masksToBounds = false
        embed(editor, in: contentView)

        assignmentStore
            .getEntitiesFromDatabase()
            .first()
            .compactMap { $0.first }
            .sink(
                receiveCompletion: { _ in }) { [weak self] assignment in
                    guard let self = self else { return }
                    self.assignment = assignment
                    guard loadDraft else { return }
                    self.updateEditor(assignment.draftText)
                }
                .store(in: &subscriptions)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
    }

    func rce(_ editor: RichContentEditorViewController, canSubmit: Bool) {
        editor.getHTML { [weak self] string in
            if !string.isEmpty {
                self?.assignment?.draftText = string
            } else {
                self?.assignment?.draftText = nil
            }
            try? AppEnvironment.shared.database.viewContext.save()
        }

        deleteButton.isEnabled = canSubmit
        submitButton.isEnabled = canSubmit
    }

    func rce(_ editor: RichContentEditorViewController, didError error: Error) {
        showError(error)
    }

    @objc func submit() {
        editor.getHTML { (html: String) in
            CreateSubmission(
                context: .course(self.courseID),
                assignmentID: self.assignmentID,
                userID: self.userID,
                submissionType: .online_text_entry,
                body: html
            ).fetch { [weak self] (_, _, error) in performUIUpdate {
                if let error = error {
                    self?.showError(error)
                } else {
                    self?.assignment?.draftText = nil
                    self?.dismiss(animated: true, completion: nil)
                }
            } }
        }
    }

    private func updateEditor(_ draftText: String?) {
        if let draftText = draftText {
            editor.setHTML(draftText)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.editor.focus()
            }
        }
    }

    @objc func deleteDraftDidTap() {
        let alert = UIAlertController(
            title: NSLocalizedString("Delete draft", bundle: .student, comment: ""),
            message: NSLocalizedString("Do you want to delete your draft?", bundle: .student, comment: ""),
            preferredStyle: .alert
        )
        let ok = UIAlertAction(
            title: NSLocalizedString("Yes", bundle: .core, comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.assignment?.draftText = nil
            try? AppEnvironment.shared.database.viewContext.save()
            self?.dismiss(animated: true, completion: nil)
        }
        let cancelTitle = NSLocalizedString("No", bundle: .core, comment: "")
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
