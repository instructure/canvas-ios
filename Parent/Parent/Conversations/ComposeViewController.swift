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

class ComposeViewController: UIViewController, ErrorViewController {
    weak var bodyMinHeight: NSLayoutConstraint!
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var recipientsView: ComposeRecipientsView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var subjectField: UITextField!

    var context: Context?
    let env = AppEnvironment.shared
    var keyboard: KeyboardTransitioning?
    var observeeID: String?

    static func create(
        body: String?,
        context: Context?,
        observeeID: String?,
        recipients: [APIConversationRecipient],
        subject: String?
    ) -> ComposeViewController {
        let controller = loadFromStoryboard()
        controller.loadViewIfNeeded()
        controller.bodyView.text = body
        controller.context = context
        controller.observeeID = observeeID
        controller.recipientsView.recipients = recipients
        controller.subjectField.text = subject
        controller.textViewDidChange(controller.bodyView)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)

        title = NSLocalizedString("New Message", comment: "")
        addCancelButton(side: .left)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Send", comment: ""), style: .done, target: self, action: #selector(send))
        navigationItem.rightBarButtonItem?.isEnabled = false

        bodyMinHeight = bodyView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        bodyMinHeight.isActive = true
        bodyView.placeholder = NSLocalizedString("Message", comment: "")
        bodyView.placeholderColor = .named(.textDark)
        bodyView.font = .scaledNamedFont(.medium16)
        bodyView.textColor = .named(.textDarkest)
        bodyView.textContainerInset = UIEdgeInsets(top: 15.5, left: 11, bottom: 15, right: 11)

        subjectField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Subject", comment: ""),
            attributes: [ .foregroundColor: UIColor.named(.textDark) ]
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        navigationController?.navigationBar.useModalStyle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bodyMinHeight.constant = -bodyView.frame.minY
    }

    @IBAction func updateSendButton() {
        navigationItem.rightBarButtonItem?.isEnabled = (
            bodyView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            subjectField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        )
    }

    @objc func send() {
    }
}

extension ComposeViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        updateSendButton()
    }
}
