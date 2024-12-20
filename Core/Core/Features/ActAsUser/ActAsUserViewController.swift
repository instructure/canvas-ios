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

public class ActAsUserViewController: UIViewController {
    @IBOutlet weak var actAsUserButton: UIButton!
    @IBOutlet weak var actAsUserDescription: UILabel!
    @IBOutlet weak var domainTextField: UITextField!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var redPanda: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userIDTextField: UITextField!

    let env = AppEnvironment.shared
    var initialUserID: String?
    var keyboard: KeyboardTransitioning?
    weak var loginDelegate: LoginDelegate?

    public static func create(loginDelegate: LoginDelegate, userID: String? = nil) -> ActAsUserViewController {
        let controller = loadFromStoryboard()
        controller.initialUserID = userID
        controller.loginDelegate = loginDelegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        addCancelButton(side: .left)
        title = String(localized: "Act as User", bundle: .core)
        navigationItem.rightBarButtonItem = nil // remove Done added by Helm
        // swiftlint:disable:next line_length
        actAsUserDescription.text = String(localized: "\"Act as\" is essentially logging in as this user without a password. You will be able to take any action as if you were this user, and from other users' points of view, as if this user performed them. However, audit logs record that you were the one who performed the actions on behalf of this user.", bundle: .core)
        domainTextField.placeholder = String(localized: "Domain", bundle: .core)
        userIDTextField.placeholder = String(localized: "User ID", bundle: .core)
        actAsUserButton.titleLabel?.text = String(localized: "Act as User", bundle: .core)
        domainTextField.text = env.currentSession?.baseURL.absoluteString
        userIDTextField.text = initialUserID
        updateActAsUserButtonDisabledStatus()

        domainTextField.addTarget(self, action: #selector(updateActAsUserButtonDisabledStatus), for: .editingChanged)
        userIDTextField.addTarget(self, action: #selector(updateActAsUserButtonDisabledStatus), for: .editingChanged)

        domainTextField.addTarget(self, action: #selector(actAsUserPressed), for: .editingDidEndOnExit)
        userIDTextField.addTarget(self, action: #selector(actAsUserPressed), for: .editingDidEndOnExit)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        navigationController?.navigationBar.useModalStyle()
        animatePanda()
    }

    func animatePanda() {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let easeInEaseOut = CAMediaTimingFunction(name: .easeInEaseOut)
        let cover = CATransform3DIdentity
        let aside = CATransform3DMakeAffineTransform(redPanda.transform.translatedBy(x: -82, y: 30).rotated(by: .pi / -6))
        animation.timingFunctions = [ easeInEaseOut, easeInEaseOut, easeInEaseOut, easeInEaseOut ]
        animation.duration = 10
        animation.keyTimes = [ 0, 0.2, 0.35, 0.85, 1 ]
        animation.values = [ aside, aside, cover, cover, aside ]
        animation.repeatCount = .infinity
        redPanda.layer.add(animation, forKey: "masquerade")
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let info = notification.userInfo as? [String: Any],
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        let y = max(0, scrollView.contentSize.height - scrollView.safeAreaInsets.bottom - scrollView.convert(keyboardFrame, from: nil).origin.y)
        UIView.animate(withDuration: animationDuration, delay: 0, options: .init(rawValue: animationCurve), animations: {
            self.scrollView.contentOffset.y = y
            self.scrollView.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func updateActAsUserButtonDisabledStatus() {
        actAsUserButton.isEnabled = (
            domainTextField.text?.isEmpty == false &&
            userIDTextField.text?.isEmpty == false
        )
        actAsUserButton.alpha = actAsUserButton.isEnabled ? 1 : 0.5
    }

    @IBAction func actAsUserPressed() {
        guard
            var host = domainTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !host.isEmpty,
            let userID = userIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userID.isEmpty
        else { return }
        if !host.contains(".") {
            host = "\(host).instructure.com"
        }
        if URLComponents.parse(host).scheme == nil {
            host = "https://\(host)"
        }
        guard let baseURL = URL(string: host), let session = env.currentSession else {
            return showMasqueradingError()
        }
        view.endEditing(true)
        let api = API(session, baseURL: baseURL)
        api.makeRequest(GetUserRequest(userID: userID)) { [weak self] (user, _, error) in performUIUpdate {
            guard let self = self else { return }
            guard let user = user, error == nil else {
                return self.showMasqueradingError()
            }
            self.env.router.dismiss(self)
            self.loginDelegate?.startActing(as: LoginSession(
                accessToken: session.accessToken,
                baseURL: baseURL,
                expiresAt: session.expiresAt,
                lastUsedAt: Clock.now,
                locale: user.locale ?? user.effective_locale,
                masquerader: (session.originalBaseURL ?? session.baseURL)
                    .appendingPathComponent("users")
                    .appendingPathComponent(session.originalUserID ?? session.userID),
                refreshToken: session.refreshToken,
                userAvatarURL: user.avatar_url?.rawValue,
                userID: user.id.value,
                userName: user.short_name,
                userEmail: user.email,
                clientID: session.clientID,
                clientSecret: session.clientSecret
            ))
        } }
    }

    func showMasqueradingError() {
        let alert = UIAlertController(
            title: String(localized: "Error", bundle: .core),
            message: String(localized: "There was an error with Act as User. Please try again later.", bundle: .core),
            preferredStyle: .alert
        )
        alert.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
        env.router.show(alert, from: self, options: .modal())
    }
}
