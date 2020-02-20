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

public class ActAsUserViewController: UITableViewController {
    var env: AppEnvironment?
    var presenter: ActAsUserPresenter?
    var initialUserID: String?

    @IBOutlet var redPanda: UIImageView!
    @IBOutlet var redPandaTopConstraint: NSLayoutConstraint!
    @IBOutlet var redPandaTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var actAsUserDescription: UILabel!
    @IBOutlet var domainTextField: UITextField!
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var actAsUserButton: UIButton!

    public static func create(env: AppEnvironment = .shared, loginDelegate: LoginDelegate, userID: String? = nil) -> ActAsUserViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.initialUserID = userID
        controller.presenter = ActAsUserPresenter(env: env, loginDelegate: loginDelegate)
        return controller
    }

    override public func viewDidLoad() {
        tableView.backgroundColor = .named(.backgroundLightest)
        navigationItem.rightBarButtonItems = [] // remove Done added by Helm
        addCancelButton()
        title = NSLocalizedString("Act as User", bundle: .core, comment: "")
        // swiftlint:disable:next line_length
        actAsUserDescription.text = NSLocalizedString("\"Act as\" is essentially logging in as this user without a password. You will be able to take any action as if you were this user, and from other users' points of view, as if this user performed them. However, audit logs record that you were the one who performed the actions on behalf of this user.", bundle: .core, comment: "")
        domainTextField.placeholder = NSLocalizedString("Domain", bundle: .core, comment: "")
        userIDTextField.placeholder = NSLocalizedString("User ID", bundle: .core, comment: "")
        actAsUserButton.titleLabel?.text = NSLocalizedString("Act as User", bundle: .core, comment: "")
        domainTextField.text = env?.currentSession?.baseURL.absoluteString
        userIDTextField.text = initialUserID

        domainTextField.addTarget(self, action: #selector(updateActAsUserButtonDisabledStatus), for: .editingChanged)
        userIDTextField.addTarget(self, action: #selector(updateActAsUserButtonDisabledStatus), for: .editingChanged)
        actAsUserButton.isEnabled = false

        domainTextField.addTarget(self, action: #selector(enterPressed), for: .editingDidEndOnExit)
        userIDTextField.addTarget(self, action: #selector(enterPressed), for: .editingDidEndOnExit)

        redPanda.transform = redPanda.transform.rotated(by: .pi / -6).translatedBy(x: 0, y: 0)
        actAsUserButton.layer.cornerRadius = 5
        animatePanda()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
    }

    func animatePanda() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.redPandaTopConstraint.constant -= 30
            self?.redPandaTrailingConstraint.constant -= 82
            UIView.animate(withDuration: 1.5, animations: { [weak self] in
                guard let redPanda = self?.redPanda else {
                    return
                }

                redPanda.transform = redPanda.transform
                    .rotated(by: .pi / 6)
                self?.view.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    self?.redPandaTopConstraint.constant += 30
                    self?.redPandaTrailingConstraint.constant += 82
                    UIView.animate(withDuration: 1.5, delay: 5, animations: { [weak self] in
                        guard let redPanda = self?.redPanda else {
                            return
                        }
                        redPanda.transform = redPanda.transform
                            .rotated(by: .pi / -6)
                        self?.view.layoutIfNeeded()
                    }, completion: { [weak self] _ in
                        self?.animatePanda()
                    })
            })
        }
    }

    func showMasqueradingError() {
        let alert = UIAlertController(
            title: NSLocalizedString("Error", bundle: .core, comment: ""),
            message: NSLocalizedString("There was an error with Act as User. Please try again later.", bundle: .core, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func actAsUserPressed(_ sender: UIButton) {
        guard let domain = domainTextField.text, let userID = userIDTextField.text else {
            return
        }
        view.endEditing(true)
        presenter?.didSubmit(domain: domain, userID: userID) { [weak self] err in
            guard err == nil else {
                self?.showMasqueradingError()
                return
            }
            self?.dismiss(animated: true)
        }
    }
}

extension ActAsUserViewController {
    @objc
    func updateActAsUserButtonDisabledStatus() {
        self.actAsUserButton.isEnabled = domainTextField.text?.isEmpty == false && userIDTextField.text?.isEmpty == false
    }

    @objc
    func enterPressed() {
        if self.actAsUserButton.isEnabled {
            self.actAsUserPressed(self.actAsUserButton)
        }
    }
}
