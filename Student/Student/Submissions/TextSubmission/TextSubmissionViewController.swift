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

class TextSubmissionViewController: UIViewController, ErrorViewController, RichContentEditorDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!

    var agent: SubmissionAgent!
    var editor: RichContentEditorViewController!
    let env = AppEnvironment.shared
    var keyboard: KeyboardTransitioning?

    static func create(agent: SubmissionAgent) -> TextSubmissionViewController {
        let controller = loadFromStoryboard()
        controller.agent = agent
        controller.editor = RichContentEditorViewController.create(context: agent.context, uploadTo: .myFiles)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = String(localized: "Text Entry", bundle: .student)

        navigationController?.navigationBar.useModalStyle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Submit", bundle: .student), style: .plain, target: self, action: #selector(submit))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "TextSubmission.submitButton"
        navigationItem.rightBarButtonItem?.isEnabled = false
        addCancelButton(side: .left)

        editor.delegate = self
        editor.placeholder = String(localized: "Write...", bundle: .student, comment: "Text submission editor placeholder")
        editor.a11yLabel = String(localized: "Submission text", bundle: .student, comment: "Text submission editor accessibility label")
        editor.webView.scrollView.layer.masksToBounds = false
        embed(editor, in: contentView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
    }

    func rce(_ editor: RichContentEditorViewController, canSubmit: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = canSubmit
    }

    func rce(_ editor: RichContentEditorViewController, didError error: Error) {
        showError(error)
    }

    @objc func submit() {

        editor.getHTML { (html: String) in
            CreateSubmission(
                agent: self.agent,
                submissionType: .online_text_entry,
                body: html
            ).fetch { (_, _, error) in performUIUpdate {
                if let error = error {
                    self.showError(error)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            } }
        }
    }
}
