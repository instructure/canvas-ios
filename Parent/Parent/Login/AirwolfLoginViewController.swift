//
//  LoginViewController.swift
//  Parent
//
//  Created by Ben Kraus on 4/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import TooLegit
import SoPretty
import SoLazy
import ReactiveCocoa
import Marshal
import Airwolf
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
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var fields: [UITextField]!

    @IBOutlet var loginStateItems: [UIView]!
    @IBOutlet var createAccountStateItems: [UIView]!
    @IBOutlet var forgotPasswordStateItems: [UIView]!
    @IBOutlet var changePasswordStateItems: [UIView]!
    @IBOutlet var allItems: [UIView]!

    @IBOutlet var fieldContainerHeightConstraint: NSLayoutConstraint!
    private let loginFieldContainerHeight: CGFloat = 85.0
    private let resetPasswordContainerHeight: CGFloat = 42.0
    private let createAccountFieldContainerHeight: CGFloat = 214.0

    @IBOutlet var emailFieldTopCollapsedConstraint: NSLayoutConstraint!
    @IBOutlet var passwordFieldTopCollapsedConstraint: NSLayoutConstraint!
    private let passwordTopDefault: CGFloat = 135.0
    private let passwordTopCollapsed: CGFloat = 6.0

    enum State {
        case DoingSomethingImportant
        case Disabled
        case Login
        case CreateAccount
        case ForgotPassword
        case ChangePassword
    }

    private (set) var state: MutableProperty<State>
    private var viewDidLoadFinished: Bool = false
    private var reachability: Reachability?

    let changePasswordInfo: (email: String, token: String)?

    var loggedInHandler: ((session: Session)->Void)?

    init(changePasswordInfo: (email: String, token: String)? = nil) {
        self.changePasswordInfo = changePasswordInfo
        if changePasswordInfo != nil {
            self.state = MutableProperty(.ChangePassword)
        } else {
            self.state = MutableProperty(.Login)
        }
        super.init(nibName: "AirwolfLoginViewController", bundle: NSBundle(forClass: AirwolfLoginViewController.classForCoder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let colors = ColorScheme.blueColorScheme
        triangleBackgroundGradientView.diagonal = false
        triangleBackgroundGradientView.transitionToColors(colors.tintBottomColor, tintBottomColor: colors.tintTopColor) // Flip the colors the other way

        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            reachability?.whenReachable = { [weak self] availability in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.checkRegion()
                }
            }

            reachability?.whenUnreachable = { [weak self] reachability in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.state.value = .Disabled
                }
            }
            try reachability?.startNotifier()
        } catch {
            print("Unable to create or start reachability notifier")
        }

        primaryButton.rac_enabled <~ combineLatest(firstNameField.rac_text.producer, lastNameField.rac_text.producer, emailField.rac_text.producer, passwordField.rac_text.producer, confirmPasswordField.rac_text.producer, state.producer).map { (firstName, lastName, email, password, confirmedPassword, state) in
            let emailValid = self.isValidEmail(email)

            switch state {
            case .DoingSomethingImportant, .Disabled:
                return false
            case .Login:
                return emailValid && password.characters.count > 0
            case .CreateAccount:
                return emailValid && password.characters.count > 0 && password == confirmedPassword && firstName.characters.count > 0 && lastName.characters.count > 0
            case .ForgotPassword:
                return emailValid
            case .ChangePassword:
                return password.characters.count > 0 && password == confirmedPassword
            }
        }
        primaryButton.rac_title <~ state.producer.map {
            switch $0 {
            case .DoingSomethingImportant:
                return nil
            case .Login, .Disabled:
                return NSLocalizedString("Login", comment: "Submits the login form")
            case .CreateAccount:
                return NSLocalizedString("Create Account", comment: "Submits the form to create an account")
            case .ForgotPassword, .ChangePassword:
                return NSLocalizedString("Submit", comment: "Button title for forgot password")
            }
        }

        primaryButton.rac_a11yLabel <~ state.producer.map {
            switch $0 {
            case .DoingSomethingImportant:
                return nil
            case .Login, .Disabled:
                return NSLocalizedString("Login", comment: "Submits the login form")
            case .CreateAccount:
                return NSLocalizedString("Create Account", comment: "Submits the form to create an account")
            case .ForgotPassword, .ChangePassword:
                return NSLocalizedString("Submit", comment: "Button title for forgot password")
            }
        }

        primaryButton.rac_enabled.producer.startWithNext { [unowned self] enabled in
            self.primaryButton.alpha = enabled ? 1.0 : 0.7
        }

        state.producer.startWithNext { [unowned self] next in
            switch next {
            case .DoingSomethingImportant:
                self.activityIndicator.startAnimating()
            case .Login, .Disabled:
                if !self.emailField.isFirstResponder() { self.emailField.becomeFirstResponder() } // in case any other field was the first responder
                self.activityIndicator.stopAnimating()

                self.fieldContainerHeightConstraint.constant = self.loginFieldContainerHeight
                self.emailFieldTopCollapsedConstraint.active = true
                self.passwordFieldTopCollapsedConstraint.constant = self.passwordTopDefault
                self.passwordFieldTopCollapsedConstraint.active = false

                self.emailField.updateReturnKey(toType: .Next)
                self.passwordField.updateReturnKey(toType: .Done)

                self.showItemsForState(next)

            case .CreateAccount:
                // if we were in the email field from login, move up in the sheet
                if self.emailField.isFirstResponder() { self.firstNameField.becomeFirstResponder() }
                self.activityIndicator.stopAnimating()

                self.fieldContainerHeightConstraint.constant = self.createAccountFieldContainerHeight
                self.emailFieldTopCollapsedConstraint.active = false
                self.passwordFieldTopCollapsedConstraint.constant = self.passwordTopDefault
                self.passwordFieldTopCollapsedConstraint.active = false

                self.emailField.updateReturnKey(toType: .Next)
                self.passwordField.updateReturnKey(toType: .Next)
                self.confirmPasswordField.updateReturnKey(toType: .Done)

                self.showItemsForState(next)

            case .ForgotPassword:
                // The only field available, jump right to that
                self.emailField.becomeFirstResponder()

                self.activityIndicator.stopAnimating()

                self.fieldContainerHeightConstraint.constant = self.resetPasswordContainerHeight
                self.emailFieldTopCollapsedConstraint.active = true
                self.passwordFieldTopCollapsedConstraint.constant = self.passwordTopDefault
                self.passwordFieldTopCollapsedConstraint.active = false

                self.emailField.updateReturnKey(toType: .Done)

                self.showItemsForState(next)

            case .ChangePassword:
                self.passwordField.becomeFirstResponder()

                self.activityIndicator.stopAnimating()

                self.fieldContainerHeightConstraint.constant = self.loginFieldContainerHeight
                self.emailFieldTopCollapsedConstraint.active = false
                self.passwordFieldTopCollapsedConstraint.constant = self.passwordTopCollapsed
                self.passwordFieldTopCollapsedConstraint.active = true

                self.passwordField.updateReturnKey(toType: .Next)
                self.confirmPasswordField.updateReturnKey(toType: .Done)

                self.showItemsForState(next)
            }

            if next != .DoingSomethingImportant {
                self.view.setNeedsUpdateConstraints()
                UIView.animateWithDuration(self.viewDidLoadFinished ? 0.3 : 0.0) {
                    self.view.layoutIfNeeded()
                }
            }
        }

        checkRegion()

        viewDidLoadFinished = true
    }

    private func checkRegion() {
        if RegionPicker.defaultPicker.pickedRegion() == nil {
            state.value = .DoingSomethingImportant
            RegionPicker.defaultPicker.pickBestRegion { url in
                if let url = url {
                    AirwolfAPI.baseURL = url
                    self.state.value = .Login
                } else {
                    self.state.value = .Disabled
                }
            }
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }


    @IBAction func dismissKeyboard(gesture: UITapGestureRecognizer) {
        for field in fields {
            field.resignFirstResponder()
        }
    }

    @IBAction func primaryButtonTapped(button: UIButton) {
        switch state.value {
        case .DoingSomethingImportant, .Disabled:
            break
        case .Login:
            attemptLogin(email: emailField.text ?? "", password: passwordField.text ?? "")
        case .CreateAccount:
            createAccount(email: emailField.text ?? "", password: passwordField.text ?? "", confirmedPassword: confirmPasswordField.text ?? "", firstName: firstNameField.text ?? "", lastName: lastNameField.text ?? "")
        case .ForgotPassword:
            sendPasswordResetEmail(email: emailField.text ?? "")
        case .ChangePassword:
            changePassword(password: passwordField.text ?? "", confirmedPassword: confirmPasswordField.text ?? "")
        }
    }

    @IBAction func createAccountButtonTapped(button: UIButton) {
        state.value = .CreateAccount
        clearFields()
    }

    @IBAction func forgotPasswordButtonTapped(button: UIButton) {
        state.value = .ForgotPassword
        clearFields()
    }

    @IBAction func cancelButtonTapped(button: UIButton) {
        state.value = .Login
        clearFields()
    }

    func clearFields() {
        // clear all the fields between state changes
        for field in fields {
            field.text = ""
        }
    }

    func showItemsForState(state: State) {
        let allItems = Set(self.allItems)
        let visibleItems: Set<UIView>
        switch state {
        case .Login, .Disabled:
            visibleItems = Set(self.loginStateItems)
        case .CreateAccount:
            visibleItems = Set(self.createAccountStateItems)
        case .ForgotPassword:
            visibleItems = Set(self.forgotPasswordStateItems)
        case .ChangePassword:
            visibleItems = Set(self.changePasswordStateItems)
        default:
            visibleItems = Set()
        }
        let hiddenItems = allItems.subtract(visibleItems)

        for visibleItem in visibleItems {
            visibleItem.hidden = false
        }

        for hiddenItem in hiddenItems {
            hiddenItem.hidden = true
        }
    }

    func isValidEmail(str: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(str)
    }

    func attemptLogin(email email: String, password: String) {
        guard isValidEmail(email) else { return }
        guard password.characters.count > 0 else { return }
        guard state.value != .DoingSomethingImportant else { return }

        state.value = .DoingSomethingImportant

        do {
            try Airwolf.authenticate(email: email, password: password).producer.startWithSignal { [unowned self] signal, disposable in
                signal.observeOn(UIScheduler()).observe { [unowned self] event in
                    switch event {
                    case .Failed(let e):
                        self.state.value = .Login

                        print("Error authenticating: \(e)")
                        let alert = UIAlertController(title: NSLocalizedString("Invalid Credentials", comment: "Alert title when logging in with invalid credentials"), message: NSLocalizedString("The email and password combination were invalid", comment: "Alert message when logging in with invalid credentials"), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    case .Interrupted:
                        self.state.value = .Login
                        print("Authentication interrupted")
                    default:
                        guard let value = event.value else { return }
                        if let token: String = try? value <| "token", parentID: String = try? value <| "parent_id" {
                            let user = SessionUser(id: parentID, name: "", email: email)
                            let session = Session(baseURL: AirwolfAPI.baseURL, user: user, token: token)

                            do {
                                let refresher = try Student.observedStudentsRefresher(session)
                                refresher.refreshingCompleted.observeNext { _ in
                                    self.state.value = .Login
                                    self.loggedInHandler?(session: session)
                                }
                                refresher.refresh(true)
                            } catch let e as NSError {
                                self.state.value = .Login
                                print(e)
                            }
                        }
                    }
                }
            }
        } catch {
            state.value = .Login
            print(error)
        }
    }

    func createAccount(email email: String, password: String, confirmedPassword: String, firstName: String, lastName: String) {
        guard isValidEmail(email) else { return }
        guard password == confirmedPassword && password.characters.count > 0 else { return }
        guard firstName.characters.count > 0 && lastName.characters.count > 0 else { return }
        guard state.value != .DoingSomethingImportant else { return }

        state.value = .DoingSomethingImportant

        do {
            try Airwolf.createAccount(email: email, password: password, firstName: firstName, lastName: lastName).producer.startWithSignal { [unowned self] signal, disposable in
                signal.observeOn(UIScheduler()).observe { [unowned self] event in
                    self.state.value = .CreateAccount

                    switch event {
                    case .Failed(let e):
                        print("Error creating account: \(e)")
                        let createAccountTitle = NSLocalizedString("Unable to Create Account", comment: "Title for alert when failing to create account")
                        var createAccountMessage = NSLocalizedString("We couldn't create your account. Double check your information or try again later.", comment: "Error message when failing to create account")
                        if e.code == 400 {
                            createAccountMessage = e.localizedDescription
                        }

                        let alert = UIAlertController(title: createAccountTitle, message: createAccountMessage, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    case .Interrupted:
                        print("Create account interrupted")
                    default:
                        guard let value = event.value else { return }
                        if let token: String = try? value <| "token", parentID: String = try? value <| "parent_id" {
                            let user = SessionUser(id: parentID, name: "")
                            let session = Session(baseURL: AirwolfAPI.baseURL, user: user, token: token)
                            self.loggedInHandler?(session: session)
                        }
                    }
                }
            }
        } catch {
            state.value = .CreateAccount
            print(error)
        }
    }

    func sendPasswordResetEmail(email email: String) {
        guard isValidEmail(email) else { return }
        guard state.value != .DoingSomethingImportant else { return }

        state.value = .DoingSomethingImportant

        do {
            try Airwolf.sendPasswordResetEmail(email: email).producer.startWithSignal { [unowned self] signal, disposable in
                signal.observeOn(UIScheduler()).observe { [unowned self] event in
                    self.state.value = .ForgotPassword

                    switch event {
                    case .Failed(let e):
                        if e.code == 404 {
                            let alert = UIAlertController(title: NSLocalizedString("Email Not Found", comment: "Title for alert shown when the server couldn't find an email to reset the password for"), message: NSLocalizedString("We couldn't find an account associated with that email. Double check that you entered it correctly and try again.", comment: "Body for alert shown when the server couldn't find an email to reset the password for"), preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: NSLocalizedString("Problem Resetting Password", comment: "Title for alert shown when something goes wrong resetting the password"), message: NSLocalizedString("Something went wrong while attempting to send a password reset email. Try again later.", comment: "Body for alert shown when something goes wrong resetting the password"), preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    case .Completed:
                        let alert = UIAlertController(title: NSLocalizedString("Email Sent", comment: "Title for alert shown when user attempts to reset their password"), message: NSLocalizedString("You will receive an email shortly to finish the process of resetting your password.", comment: "Body for alert shown when resetting password"), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { _ in
                            self.state.value = .Login
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                }
            }
        } catch {
            state.value = .ForgotPassword
            print(error)
        }
    }

    func changePassword(password password: String, confirmedPassword: String) {
        guard password == confirmedPassword && password.characters.count > 0 else { return }
        guard state.value != .DoingSomethingImportant else { return }
        guard let changePasswordInfo = changePasswordInfo else { return }

        state.value = .DoingSomethingImportant

        do {
            try Airwolf.resetPassword(email: changePasswordInfo.email, password: password, token: changePasswordInfo.token).producer.startWithSignal { [unowned self] signal, disposable in
                signal.observeOn(UIScheduler()).observe { [unowned self] event in
                    self.state.value = .ChangePassword

                    switch event {
                    case .Failed:
                        let alert = UIAlertController(title: NSLocalizedString("Problem Resetting Password", comment: "Title for alert shown when something goes wrong resetting the password"), message: NSLocalizedString("Something went wrong while attempting to reset your password. Try again later.", comment: "Body for alert shown when something goes wrong resetting the password"), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    case .Completed:
                        let alert = UIAlertController(title: NSLocalizedString("Password Reset Successful", comment: "Title for alert when resetting password is successful"), message: NSLocalizedString("Your password has been successfully reset. Please log in now.", comment: "Body for alert after having successfully reset the password"), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { _ in
                            self.state.value = .Login
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                }
            }
        } catch {
            state.value = .ChangePassword
            print(error)
        }
    }
}

extension AirwolfLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            emailField.becomeFirstResponder()
        } else if textField === emailField {
            switch state.value {
            case .ForgotPassword:
                sendPasswordResetEmail(email: emailField.text ?? "")
            default:
                passwordField.becomeFirstResponder()
            }
        } else if textField === passwordField {
            switch state.value {
            case .DoingSomethingImportant, .ForgotPassword, .Disabled:
                break
            case .Login:
                attemptLogin(email: emailField.text ?? "", password: passwordField.text ?? "")
            case .CreateAccount, .ChangePassword:
                confirmPasswordField?.becomeFirstResponder()
            }
        } else if textField === confirmPasswordField {
            switch state.value {
            case .DoingSomethingImportant, .Login, .ForgotPassword, .Disabled: break
            case .CreateAccount:
                createAccount(email: emailField.text ?? "", password: passwordField.text ?? "", confirmedPassword: confirmPasswordField.text ?? "", firstName: firstNameField.text ?? "", lastName: lastNameField.text ?? "")
            case .ChangePassword:
                changePassword(password: passwordField.text ?? "", confirmedPassword: confirmPasswordField.text ?? "")
            }
        }
        return false
    }
}
