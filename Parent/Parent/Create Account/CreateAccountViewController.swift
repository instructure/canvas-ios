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
import Core

class CreateAccountViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var name: CreateAccountRow!
    @IBOutlet weak var email: CreateAccountRow!
    @IBOutlet weak var password: CreateAccountRow!
    @IBOutlet weak var createAccountButton: ActivityIndicatorButton!
    @IBOutlet weak var termsAndConditionsTextView: UITextView!
    @IBOutlet weak var alreadyHaveAccountLabel: DynamicLabel!
    @IBOutlet weak var termsAndConditionsTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollPadding: NSLayoutConstraint!
    var selectedTextField: UITextField?
    var baseURL: URL?
    var accountID: String = ""
    var pairingCode: String = ""

    static func create(baseURL: URL, accountID: String, pairingCode: String) -> CreateAccountViewController {
        let vc = loadFromStoryboard()
        vc.baseURL = baseURL
        vc.accountID = accountID
        vc.pairingCode = pairingCode
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.keyboardDismissMode = .interactive

        navigationController?.setNavigationBarHidden(true, animated: false)

        name.labelName.text = NSLocalizedString("Full name", comment: "")
        name.textField.placeholder = NSLocalizedString("Full name...", comment: "")
        name.errorLabel.text = nil
        name.textField.delegate = self
        name.textField.returnKeyType = .next

        email.textField.keyboardType = .emailAddress
        email.labelName.text = NSLocalizedString("Email address", comment: "")
        email.textField.placeholder = NSLocalizedString("Email...", comment: "")
        email.errorLabel.text = nil
        email.textField.delegate = self
        email.textField.returnKeyType = .next

        password.textField.isSecureTextEntry = true
        password.labelName.text = NSLocalizedString("Password", comment: "")
        password.textField.placeholder = NSLocalizedString("Password...", comment: "")
        password.textField.delegate = self
        password.errorLabel.text = nil
        password.textField.returnKeyType = .done

        createAccountButton.layer.cornerRadius = 4

        createAccountButton.setTitle(NSLocalizedString("Create Account", comment: ""), for: .normal)
        termsAndConditionsTextView.attributedText = termsOfServicePrivacyPolicyAttributedString()
        termsAndConditionsTextView.delegate = self
        termsAndConditionsTextView.tintColor = .named(.electric)

        alreadyHaveAccountLabel.attributedText = footerAttributedString()

        stackView.setCustomSpacing(16, after: termsAndConditionsTextView)
        stackView.setCustomSpacing(16, after: createAccountButton)

        setupKeyboardNofications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adjustTermsAndConditionsHeight()
    }

    func setupKeyboardNofications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollPadding.constant = 0
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo as? [String: Any],
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
        scrollPadding.constant = 350
        scrollView.scrollToView(view: selectedTextField, keyboardRect: keyboardFrame)
    }

    @IBAction func actionSignIn(_ sender: Any) {
        let loginNav = navigationController?.presentingViewController
        AppEnvironment.shared.router.dismiss(self) {
            AppEnvironment.shared.loginDelegate?.changeUser()
            if let nav = loginNav as? LoginNavigationController,
                let host = self.baseURL?.host {
                nav.login(host: host)
            }
        }
    }

    @IBAction func actionCreateAccount(_ sender: Any) {
        guard let baseURL = baseURL else { return }
        guard let fullname = name.textField.text, fullname.count > 2 else { rowInvalidShowError(row: name); return }
        guard let userEmail = email.textField.text, !userEmail.isEmpty else { rowInvalidShowError(row: email); return }
        guard let userPassword = password.textField.text, !userPassword.isEmpty else { rowInvalidShowError(row: password); return }

        resetRowErrors()

        let request = PostAccountUserRequest(
            baseURL: baseURL,
            accountID: accountID,
            pairingCode: pairingCode,
            name: fullname,
            email: userEmail,
            password: userPassword
        )
        createAccountButton.showSpinner(true)
        AppEnvironment.shared.api.makeRequest(request) { [weak self] (_, _, error) in
            performUIUpdate {
                self?.createAccountButton.showSpinner(false)
                if let error = error {
                    self?.showError(error)
                    return
                }
                self?.dismissCreateAccount()
            }
        }
    }

    func rowInvalidShowError(row: CreateAccountRow) {
        resetRowErrors()
        row.textField.layer.borderColor = UIColor.named(.borderDanger).cgColor

        switch row {
        case name: return
            row.errorLabel.text = NSLocalizedString("Please enter full name", comment: "")
        case email: return
            row.errorLabel.text = NSLocalizedString("Please enter an email address", comment: "")
        case password: return
            row.errorLabel.text = NSLocalizedString("Password is required", comment: "")
        default: return
        }
    }

    func resetRowErrors() {
        let rows = [name, email, password]
        rows.forEach {
            $0?.textField.layer.borderWidth = 1
            $0?.textField.layer.cornerRadius = 4
            $0?.textField.layer.borderColor = UIColor.named(.borderMedium).cgColor
            $0?.errorLabel.text = nil
        }
    }

    func dismissCreateAccount() {
        AppEnvironment.shared.router.dismiss(self) {
            if let delegate = AppEnvironment.shared.loginDelegate { delegate.changeUser() }
        }
    }

    func keyboardDidChangeState(keyboardFrame: CGRect) {
        scrollView.scrollToView(view: selectedTextField, keyboardRect: keyboardFrame)
    }

    func termsOfServicePrivacyPolicyAttributedString() -> NSAttributedString {
        let privacyPolicy = NSLocalizedString("Privacy Policy", comment: "Link text in 'By tapping ‘Create Account’, you agree to the %@ and acknowledge the %@.'")
        let terms = NSLocalizedString("Terms of Service", comment: "Link text in 'By tapping ‘Create Account’, you agree to the %@ and acknowledge the %@.'")
        let str = NSLocalizedString("By tapping ‘Create Account’, you agree to the %@ and acknowledge the %@.", comment: "")
        let message = String.localizedStringWithFormat(str, terms, privacyPolicy)
        let attributes = [
            NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular14),
            NSAttributedString.Key.foregroundColor: UIColor.named(.textDark),
        ]
        let attributed = NSMutableAttributedString(string: message, attributes: attributes)
        attributed.addAttribute(
            .link,
            value: "https://www.instructure.com/policies/acceptable-use?newhome=canvas",
            range: (message as NSString).range(of: terms)
        )
        attributed.addAttribute(
            .link,
            value: "https://www.instructure.com/policies/privacy?newhome=canvas",
            range: (message as NSString).range(of: privacyPolicy)
        )
        return attributed
    }

    func footerAttributedString() -> NSAttributedString {
        let link = NSLocalizedString("Sign In", comment: "Link text in 'Already have an account? Sign In")
        let message = String.localizedStringWithFormat(NSLocalizedString("Already have an account? %@", comment: ""), link)
        let attributes = [
            NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular14),
            NSAttributedString.Key.foregroundColor: UIColor.named(.textDark),
        ]
        let attributed = NSMutableAttributedString(string: message, attributes: attributes)
        attributed.addAttribute(.foregroundColor, value: UIColor.named(.electric), range: (message as NSString).range(of: link))
        return attributed
    }

    func adjustTermsAndConditionsHeight() {
        termsAndConditionsTextView.sizeToFit()
        termsAndConditionsTextViewHeight.constant = termsAndConditionsTextView.frame.size.height
    }
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.contentOffset = CGPoint.zero
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let next: UITextField?

        switch textField {
        case name.textField: next = email.textField
        case email.textField: next = password.textField
        default: next = nil
        }

        if let next = next {
            next.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}

extension CreateAccountViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

class CreateAccountRow: UIView {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: CustomLabel!
    @IBOutlet weak var labelName: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromXib()
    }

    class CustomLabel: UILabel {
        override var text: String? {
            didSet {
                isHidden = text?.isEmpty == true
            }
        }
    }
}
