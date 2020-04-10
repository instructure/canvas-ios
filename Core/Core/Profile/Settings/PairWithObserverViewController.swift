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

import UIKit

class PairWithObserverViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var codeLabel: DynamicLabel!
    @IBOutlet weak var spinner: CircleProgressView!
    @IBOutlet weak var codeContainer: UIView!
    @IBOutlet weak var notificationView: NotificationView!
    @IBOutlet weak var notificationViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tapToCopyButton: UIButton!
    var animating: Bool = false
    var didGenerateCode = false

    let env = AppEnvironment.shared

    static func create() -> PairWithObserverViewController {
        return  loadFromStoryboard()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Pair with Observer", bundle: .core, comment: "")
        notificationView.messageLabel.text = NSLocalizedString("Copied!", bundle: .core, comment: "")
        tapToCopyButton.setTitle(NSLocalizedString("Tap to copy", bundle: .core, comment: ""), for: .normal)

        codeContainer.layer.cornerRadius = 8.0

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionShare(sender:)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didGenerateCode { generatePairingCode() }
    }

    func generatePairingCode() {
        didGenerateCode = true
        env.api.makeRequest(PostObserverPairingCodes()) { [weak self] response, _, error in
            performUIUpdate {
                self?.spinner.isHidden = true
                if let error = error {
                    self?.showError(error)
                } else {
                    self?.displayPairingCode(response?.code)
                }
            }
        }
    }

    func displayPairingCode(_ code: String?) {
        codeLabel.isHidden = false
        codeLabel.text = code
    }

    @IBAction func actionCopyCode(_ sender: Any) {
        if codeLabel.text?.isEmpty == false {
            UIPasteboard.general.string = codeLabel.text
            showNotification()
        }
    }

    @objc func actionShare(sender: UIBarButtonItem) {
        guard let code = codeLabel.text, !code.isEmpty else { return }
        let template = NSLocalizedString("Use this code to pair with me in Canvas Parent: %@", bundle: .core, comment: "")
        let message = String.localizedStringWithFormat(template, code)
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        let popover = vc.popoverPresentationController
        popover?.barButtonItem = sender
        env.router.show(vc, from: self, options: .modal(isDismissable: false, embedInNav: false, addDoneButton: false))
    }

    func showNotification(_ show: Bool = true, delay: TimeInterval = 0) {
        var completion: ((Bool) -> Void)?
        if show {
            if animating { return }
            animating = true
            notificationViewBottomConstraint.constant = 8
            completion = { _  in
                self.showNotification(false, delay: 3.0)
            }
        } else {
            notificationViewBottomConstraint.constant = -150
            completion = { _  in
                self.animating = false
            }
        }

        UIView.animate(withDuration: 0.15, delay: delay, options: .curveEaseOut, animations: { [weak self] in
            self?.notificationView.superview?.layoutIfNeeded()
        }, completion: completion)
    }
}
