//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit


import CanvasCore
import ReactiveSwift
import Marshal

import Result
import Reachability


class AirwolfLoginViewController: UIViewController {

    @IBOutlet var triangleBackgroundGradientView: TriangleBackgroundGradientView!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!
    @IBOutlet var primaryButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet weak var selectRegionButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var canvasLoginButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var fields: [UITextField]!

    @IBOutlet var loginStateItems: [UIView]!
    @IBOutlet var createAccountStateItems: [UIView]!
    @IBOutlet var forgotPasswordStateItems: [UIView]!
    @IBOutlet var changePasswordStateItems: [UIView]!
    @IBOutlet var allItems: [UIView]!

    @IBOutlet var fieldContainerHeightConstraint: NSLayoutConstraint!
    fileprivate let loginFieldContainerHeight: CGFloat = 85.0
    fileprivate let resetPasswordContainerHeight: CGFloat = 42.0
    fileprivate let createAccountFieldContainerHeight: CGFloat = 214.0

    @IBOutlet var emailFieldTopCollapsedConstraint: NSLayoutConstraint!
    @IBOutlet var passwordFieldTopCollapsedConstraint: NSLayoutConstraint!
    fileprivate let passwordTopDefault: CGFloat = 135.0
    fileprivate let passwordTopCollapsed: CGFloat = 6.0
    
    @IBOutlet weak var betaButton: UIButton!

    enum State {
        case doingSomethingImportant
        case disabled
        case login
        case createAccount
        case forgotPassword
        case changePassword
    }

    let state: MutableProperty<State>
    fileprivate var viewDidLoadFinished: Bool = false
    fileprivate var reachability = Reachability(hostName: "www.google.com")!

    let changePasswordInfo: (email: String, token: String)?

    var loggedInHandler: ((Session)->Void)?


    init(changePasswordInfo: (email: String, token: String)? = nil) {
        self.changePasswordInfo = changePasswordInfo
        if changePasswordInfo != nil {
            self.state = MutableProperty(.changePassword)
        } else {
            self.state = MutableProperty(.login)
        }
        super.init(nibName: "AirwolfLoginViewController", bundle: Bundle(for: AirwolfLoginViewController.classForCoder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let spacing: CGFloat = 20.0
        let insetAmount = spacing / 2
        
        canvasLoginButton.imageView?.contentMode = .scaleAspectFit
        if UIView.userInterfaceLayoutDirection(for: canvasLoginButton.semanticContentAttribute) == .leftToRight {
            canvasLoginButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            canvasLoginButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        }
        else {
            canvasLoginButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            canvasLoginButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            canvasLoginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -insetAmount)
        }
        
        let colors = ColorScheme.blueColorScheme
        triangleBackgroundGradientView.diagonal = false
        triangleBackgroundGradientView.transitionToColors(colors.tintBottomColor, tintBottomColor: colors.tintTopColor) // Flip the colors the other way

        reachability.reachableBlock = { [weak self] _ in
            DispatchQueue.main.async {
                self?.checkRegion()
            }
        }

        reachability.unreachableBlock = { [weak self] _ in
            DispatchQueue.main.async {
                self?.state.value = .disabled
            }
        }
        reachability.startNotifier()

        primaryButton.rac_enabled <~ SignalProducer.combineLatest(firstNameField.rac_text.producer, lastNameField.rac_text.producer, emailField.rac_text.producer, passwordField.rac_text.producer, confirmPasswordField.rac_text.producer, state.producer).map { (firstName, lastName, email, password, confirmedPassword, state) in
            let emailValid = email.isValidEmail()

            switch state {
            case .doingSomethingImportant, .disabled:
                return false
            case .login:
                return emailValid && password.characters.count > 0
            case .createAccount:
                return emailValid && password.characters.count > 0 && password == confirmedPassword && firstName.characters.count > 0 && lastName.characters.count > 0
            case .forgotPassword:
                return emailValid
            case .changePassword:
                return password.characters.count > 0 && password == confirmedPassword
            }
        }
        primaryButton.rac_title <~ state.producer.map {
            switch $0 {
            case .doingSomethingImportant:
                return ""
            case .login, .disabled:
                return NSLocalizedString("Login", comment: "Submits the login form")
            case .createAccount:
                return NSLocalizedString("Create Account", comment: "Submits the form to create an account")
            case .forgotPassword, .changePassword:
                return NSLocalizedString("Submit", comment: "Button title for forgot password")
            }
        }

        primaryButton.rac_a11yLabel <~ state.producer.map {
            switch $0 {
            case .doingSomethingImportant:
                return ""
            case .login, .disabled:
                return NSLocalizedString("Login", comment: "Submits the login form")
            case .createAccount:
                return NSLocalizedString("Create Account", comment: "Submits the form to create an account")
            case .forgotPassword, .changePassword:
                return NSLocalizedString("Submit", comment: "Button title for forgot password")
            }
        }

        primaryButton.rac_enabled.producer.startWithValues { [unowned self] enabled in
            self.primaryButton.alpha = enabled ? 1.0 : 0.7
        }
        
        state.producer.startWithValues { [unowned self] next in
            switch next {
            case .doingSomethingImportant:
                self.activityIndicator.startAnimating()
            case .login, .disabled:
                if !self.emailField.isFirstResponder { self.view.window?.findFirstResponder()?.resignFirstResponder() } // in case any other field was the first responder
                self.activityIndicator.stopAnimating()

                self.fieldContainerHeightConstraint.constant = self.loginFieldContainerHeight
                self.emailFieldTopCollapsedConstraint.isActive = true
                self.passwordFieldTopCollapsedConstraint.constant = self.passwordTopDefault
                self.passwordFieldTopCollapsedConstraint.isActive = true

                self.emailField.updateReturnKey(toType: .next)
                self.passwordField.updateReturnKey(toType: .done)

                self.showItemsForState(next)

            case .createAccount:
                // if we were in the email field from login, move up in the sheet
                if self.emailField.isFirstResponder { self.firstNameField.becomeFirstResponder() }
                self.activityIndicator.stopAnimating()

                self.fieldContainerHeightConstraint.constant = self.createAccountFieldContainerHeight
                self.emailFieldTopCollapsedConstraint.isActive = false
                self.passwordFieldTopCollapsedConstraint.constant = self.passwordTopDefault
                self.passwordFieldTopCollapsedConstraint.isActive = false

                self.emailField.updateReturnKey(toType: .next)
                self.passwordField.updateReturnKey(toType: .next)
                self.confirmPasswordField.updateReturnKey(toType: .done)

                self.showItemsForState(next)

            case .forgotPassword:
                // The only field available, jump right to that
                self.emailField.becomeFirstResponder()

                self.activityIndicator.stopAnimating()

                self.fieldContainerHeightConstraint.constant = self.resetPasswordContainerHeight
                self.emailFieldTopCollapsedConstraint.isActive = true
                self.passwordFieldTopCollapsedConstraint.constant = self.passwordTopDefault
                self.passwordFieldTopCollapsedConstraint.isActive = false

                self.emailField.updateReturnKey(toType: .done)

                self.showItemsForState(next)

            case .changePassword:
                self.passwordField.becomeFirstResponder()

                self.activityIndicator.stopAnimating()

                self.fieldContainerHeightConstraint.constant = self.loginFieldContainerHeight
                self.emailFieldTopCollapsedConstraint.isActive = false
                self.passwordFieldTopCollapsedConstraint.constant = self.passwordTopCollapsed
                self.passwordFieldTopCollapsedConstraint.isActive = true

                self.passwordField.updateReturnKey(toType: .next)
                self.confirmPasswordField.updateReturnKey(toType: .done)

                self.showItemsForState(next)
            }
            
            if next != .doingSomethingImportant {
                self.view.setNeedsUpdateConstraints()
                UIView.animate(withDuration: self.viewDidLoadFinished ? 0.3 : 0.0) {
                    self.view.layoutIfNeeded()
                }
            }
        }

        checkRegion()

        viewDidLoadFinished = true
        
        betaButton.rac_hidden <~ RegionPicker.shared.isBeta.producer.map { !$0 }
        let turnOnBeta = UITapGestureRecognizer(target: self, action: #selector(toggleBetaRegion(_:)))
        turnOnBeta.numberOfTapsRequired = 3
        turnOnBeta.numberOfTouchesRequired = 2
        view.addGestureRecognizer(turnOnBeta)
    }
    
    @IBAction func toggleBetaRegion(_ sender: Any) {
        RegionPicker.shared.isBeta.value = !RegionPicker.shared.isBeta.value
        print("url: \(String(describing: RegionPicker.shared.pickedRegion))")
    }
    
    fileprivate func checkRegion() {
        if RegionPicker.shared.pickedRegion == nil {
            state.value = .doingSomethingImportant
            RegionPicker.shared.pickBestRegion { url in
                if url != nil {
                    self.state.value = .login
                } else {
                    self.state.value = .disabled
                }
            }
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }


    @IBAction func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        for field in fields {
            field.resignFirstResponder()
        }
    }

    @IBAction func primaryButtonTapped(_ button: UIButton) {
        switch state.value {
        case .doingSomethingImportant, .disabled:
            break
        case .login:
            attemptLogin(email: emailField.text ?? "", password: passwordField.text ?? "")
        case .createAccount:
            createAccount(email: emailField.text ?? "", password: passwordField.text ?? "", confirmedPassword: confirmPasswordField.text ?? "", firstName: firstNameField.text ?? "", lastName: lastNameField.text ?? "")
        case .forgotPassword:
            sendPasswordResetEmail(email: emailField.text ?? "")
        case .changePassword:
            changePassword(password: passwordField.text ?? "", confirmedPassword: confirmPasswordField.text ?? "")
        }
    }

    @IBAction func createAccountButtonTapped(_ button: UIButton) {
        state.value = .createAccount
        clearFields()
    }

    @IBAction func forgotPasswordButtonTapped(_ button: UIButton) {
        state.value = .forgotPassword
        clearFields()
    }
    
    @IBAction func selectRegionButtonTapped(_ button: UIButton) {
        let title = NSLocalizedString("Select Region", comment: "")
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        Region.productionRegions
            .map { region in
                return UIAlertAction(title: region.name, style: .default) { _ in
                    RegionPicker.shared.pickedRegion = region
                }
            }
            .forEach(alert.addAction(_:))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = button
        alert.popoverPresentationController?.sourceRect = button.bounds
        present(alert, animated: true, completion: nil)
    }

    @IBAction func cancelButtonTapped(_ button: UIButton) {
        state.value = .login
        clearFields()
    }

    @IBAction func canvasLogin(_ sender: Any) {
        let domainPicker = SelectDomainViewController.new()
        domainPicker.useMobileVerify = false
        domainPicker.useKeymasterLogin = false
        domainPicker.dataSource = ParentSelectDomainDataSource.instance
        domainPicker.pickedDomainAction = { [weak self] url, provider in
            DispatchQueue.main.async {
                var pickedURL = url
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if let comps = components, comps.scheme == nil {
                    if let url = URL(string: "https://\(pickedURL.absoluteString)") {
                        pickedURL = url
                    }
                }
                guard let me = self, let host = URLComponents(url: pickedURL, resolvingAgainstBaseURL: false)?.host else {
                    return
                }
                let login = CanvasObserverLoginViewController(domain: host, authenticationProvider: provider) { [weak me] session in
                    RegionPicker.shared.pickRegion(for: session.baseURL)
                    me?.completeLogin(session)
                }
                
                me.navigationController?.pushViewController(login, animated: true)
            }
        }
        navigationController?.pushViewController(domainPicker, animated: true)
    }
    
    func clearFields() {
        // clear all the fields between state changes
        for field in fields {
            field.text = ""
        }
    }

    func showItemsForState(_ state: State) {
        let allItems = Set(self.allItems)
        let visibleItems: Set<UIView>
        switch state {
        case .login, .disabled:
            visibleItems = Set(self.loginStateItems)
        case .createAccount:
            visibleItems = Set(self.createAccountStateItems)
        case .forgotPassword:
            visibleItems = Set(self.forgotPasswordStateItems)
        case .changePassword:
            visibleItems = Set(self.changePasswordStateItems)
        default:
            visibleItems = Set()
        }
        let hiddenItems = allItems.subtracting(visibleItems)

        for visibleItem in visibleItems {
            visibleItem.isHidden = false
        }

        for hiddenItem in hiddenItems {
            hiddenItem.isHidden = true
        }
    }

    func attemptLogin(email: String, password: String) {
        guard email.isValidEmail() else { return }
        guard password.characters.count > 0 else { return }
        guard state.value != .doingSomethingImportant else { return }

        state.value = .doingSomethingImportant

        do {
            try Airwolf.authenticate(email: email, password: password).producer.startWithSignal { [unowned self] signal, disposable in
                signal.observe(on: UIScheduler()).observe { [unowned self] event in
                    switch event {
                    case .failed(let e):
                        self.state.value = .login

                        print("Error authenticating: \(e)")
                        let alert = UIAlertController(title: NSLocalizedString("Invalid Credentials", comment: "Alert title when logging in with invalid credentials"), message: NSLocalizedString("The email and password combination were invalid", comment: "Alert message when logging in with invalid credentials. Please check your region and try again."), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    case .interrupted:
                        self.state.value = .login
                        print("Authentication interrupted")
                    default:
                        guard let value = event.value else { return }
                        if
                            let token: String = try? value <| "token",
                            let parentID: String = try? value <| "parent_id",
                            let region = RegionPicker.shared.pickedRegion
                        {
                            let user = SessionUser(id: parentID, name: "", email: email)
                            let session = Session(baseURL: region.url, user: user, token: token)
                            self.completeLogin(session)
                        }
                    }
                }
            }
        } catch {
            state.value = .login
            print(error)
        }
    }
    
    func completeLogin(_ session: Session) {
        do {
            let refresher = try Student.observedStudentsRefresher(session)
            refresher.refreshingCompleted.observeValues { _ in
                self.state.value = .login
                self.loggedInHandler?(session)
            }
            refresher.refresh(true)
        } catch let e as NSError {
            self.state.value = .login
            print(e)
        }
    }

    func createAccount(email: String, password: String, confirmedPassword: String, firstName: String, lastName: String) {
        guard email.isValidEmail() else { return }
        guard password == confirmedPassword && password.characters.count > 0 else { return }
        guard firstName.characters.count > 0 && lastName.characters.count > 0 else { return }
        guard state.value != .doingSomethingImportant else { return }

        state.value = .doingSomethingImportant

        do {
            try Airwolf.createAccount(email: email, password: password, firstName: firstName, lastName: lastName).producer.startWithSignal { [unowned self] signal, disposable in
                signal.observe(on: UIScheduler()).observe { [unowned self] event in
                    self.state.value = .createAccount

                    switch event {
                    case .failed(let e):
                        print("Error creating account: \(e)")
                        let createAccountTitle = NSLocalizedString("Unable to Create Account", comment: "Title for alert when failing to create account")
                        var createAccountMessage = NSLocalizedString("We couldn't create your account. Double check your information or try again later.", comment: "Error message when failing to create account")
                        if e.code == 400 {
                            createAccountMessage = e.localizedDescription
                        }

                        let alert = UIAlertController(title: createAccountTitle, message: createAccountMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    case .interrupted:
                        print("Create account interrupted")
                    default:
                        guard let value = event.value else { return }
                        if
                            let token: String = try? value <| "token",
                            let parentID: String = try? value <| "parent_id",
                            let region = RegionPicker.shared.pickedRegion
                        {
                            let user = SessionUser(id: parentID, name: "")
                            let session = Session(baseURL: region.url, user: user, token: token)
                            self.loggedInHandler?(session)
                        }
                    }
                }
            }
        } catch {
            state.value = .createAccount
            print(error)
        }
    }

    func sendPasswordResetEmail(email: String) {
        guard email.isValidEmail() else { return }
        guard state.value != .doingSomethingImportant else { return }

        state.value = .doingSomethingImportant

        do {
            try Airwolf.sendPasswordResetEmail(email: email).producer.startWithSignal { [unowned self] signal, disposable in
                signal.observe(on: UIScheduler()).observe { [unowned self] event in
                    self.state.value = .forgotPassword

                    switch event {
                    case .failed(let e):
                        if e.code == 404 {
                            let alert = UIAlertController(title: NSLocalizedString("Email Not Found", comment: "Title for alert shown when the server couldn't find an email to reset the password for"), message: NSLocalizedString("We couldn't find an account associated with that email. Double check that you entered it correctly, check your region, and try again.", comment: "Body for alert shown when the server couldn't find an email to reset the password for"), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: NSLocalizedString("Problem Resetting Password", comment: "Title for alert shown when something goes wrong resetting the password"), message: NSLocalizedString("Something went wrong while attempting to send a password reset email. Try again later.", comment: "Body for alert shown when something goes wrong resetting the password"), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .completed:
                        let alert = UIAlertController(title: NSLocalizedString("Email Sent", comment: "Title for alert shown when user attempts to reset their password"), message: NSLocalizedString("You will receive an email shortly to finish the process of resetting your password.", comment: "Body for alert shown when resetting password"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                            self.state.value = .login
                        }))
                        self.present(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                }
            }
        } catch {
            state.value = .forgotPassword
            print(error)
        }
    }

    func changePassword(password: String, confirmedPassword: String) {
        guard password == confirmedPassword && password.characters.count > 0 else { return }
        guard state.value != .doingSomethingImportant else { return }
        guard let changePasswordInfo = changePasswordInfo else { return }

        state.value = .doingSomethingImportant

        do {
            try Airwolf.resetPassword(email: changePasswordInfo.email, password: password, token: changePasswordInfo.token).producer.startWithSignal { [unowned self] signal, disposable in
                signal.observe(on: UIScheduler()).observe { [unowned self] event in
                    self.state.value = .changePassword

                    switch event {
                    case .failed:
                        let alert = UIAlertController(title: NSLocalizedString("Problem Resetting Password", comment: "Title for alert shown when something goes wrong resetting the password"), message: NSLocalizedString("Something went wrong while attempting to reset your password. Try again later.", comment: "Body for alert shown when something goes wrong resetting the password"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    case .completed:
                        let alert = UIAlertController(title: NSLocalizedString("Password Reset Successful", comment: "Title for alert when resetting password is successful"), message: NSLocalizedString("Your password has been successfully reset. Please log in now.", comment: "Body for alert after having successfully reset the password"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                            self.state.value = .login
                        }))
                        self.present(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                }
            }
        } catch {
            state.value = .changePassword
            print(error)
        }
    }
}

extension AirwolfLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            emailField.becomeFirstResponder()
        } else if textField === emailField {
            switch state.value {
            case .forgotPassword:
                sendPasswordResetEmail(email: emailField.text ?? "")
            default:
                passwordField.becomeFirstResponder()
            }
        } else if textField === passwordField {
            switch state.value {
            case .doingSomethingImportant, .forgotPassword, .disabled:
                break
            case .login:
                attemptLogin(email: emailField.text ?? "", password: passwordField.text ?? "")
            case .createAccount, .changePassword:
                confirmPasswordField?.becomeFirstResponder()
            }
        } else if textField === confirmPasswordField {
            switch state.value {
            case .doingSomethingImportant, .login, .forgotPassword, .disabled: break
            case .createAccount:
                createAccount(email: emailField.text ?? "", password: passwordField.text ?? "", confirmedPassword: confirmPasswordField.text ?? "", firstName: firstNameField.text ?? "", lastName: lastNameField.text ?? "")
            case .changePassword:
                changePassword(password: passwordField.text ?? "", confirmedPassword: confirmPasswordField.text ?? "")
            }
        }
        return false
    }
}
