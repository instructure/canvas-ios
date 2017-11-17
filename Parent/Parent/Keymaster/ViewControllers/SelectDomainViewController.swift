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


public protocol SelectDomainDataSource {
    var logoImage: UIImage { get }
    var mobileVerifyName: String { get }
    var tintTopColor: UIColor { get }
    var tintBottomColor: UIColor { get }
}

public typealias PickedDomainAction = (URL, String?) -> Void // domain, authentication provider

open class SelectDomainViewController: UIViewController {

    // ---------------------------------------------
    // MARK: - typealias
    // ---------------------------------------------
    public typealias PickDomainAction = (AccountDomain) -> ()
    public typealias PickSessionAction = (Session) -> ()

    // ---------------------------------------------
    // MARK: - Keyboard CONSTANTS
    // ---------------------------------------------
    // This is ugly, but it should work consistently.
    fileprivate static let defaultKeyboardAnimationDuration: TimeInterval = 0.25
    fileprivate static let defaultKeyboardAnimationOptions: UIViewAnimationOptions = [.beginFromCurrentState, UIViewAnimationOptions(rawValue: 458752)]
    fileprivate var keyboardIsShowing = false
    fileprivate let cornerRadius: CGFloat = 7.0

    // ---------------------------------------------
    // MARK: - IBOutlets
    // ---------------------------------------------
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchDividerView: UIView!
    @IBOutlet weak var authMethodLabel: UILabel!
    var backgroundView: TriangleBackgroundGradientView!

    @IBOutlet weak var domainSelectionContainerView: UIView!
    @IBOutlet weak var multipleUsersContainerView: UIView!

    @IBOutlet weak var searchTextFieldToSuperviewConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerBottomToSuperviewConstraint: NSLayoutConstraint?

    // ---------------------------------------------
    // MARK: - Private Vars
    // ---------------------------------------------
    fileprivate var accountDomainsTableViewController: AccountDomainListViewController!
    fileprivate var selectSessionTableViewController: SelectSessionListViewController!

    // ---------------------------------------------
    // MARK: - Public Vars
    // ---------------------------------------------
    open var dataSource: SelectDomainDataSource? = nil
    open var allowMultipleUsers = false
    open var useMobileVerify = true
    open var useKeymasterLogin = true
    open var useBackButton = true
    open var prompt: String? = nil

    open var pickedDomainAction : PickedDomainAction? {
        didSet {
            if let _ = pickedDomainAction {
                accountDomainsTableViewController.pickedDomainAction = { [weak self] domain in
                    guard let me = self else { return }
                    me.searchTextField.resignFirstResponder()
                    if let url = URL(string: domain.domain) {
                        if (me.useMobileVerify) {
                            let host = url.host ?? url.absoluteString
                            me.validateMobileVerify(host)
                        } else {
                            me.pickedDomainAction?(url, domain.authenticationProvider)
                        }
                    }
                }
            }
        }
    }

    open var pickedSessionAction : ((Session) -> ())? {
        didSet {
            if let pickedSessionAction = pickedSessionAction {
                selectSessionTableViewController.pickedSessionAction = pickedSessionAction
            }
        }
    }

    var authenticationMethod: AuthenticationMethod = .default {
        didSet {
            authMethodLabel.text = authenticationMethod.displayText()
        }
    }

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    fileprivate static let defaultStoryboardName = "SelectDomainViewController"
    open static func new(_ storyboardName: String = defaultStoryboardName) -> SelectDomainViewController {
        var storyboard = storyboardName
        if storyboardName == defaultStoryboardName && UIDevice.current.userInterfaceIdiom == .pad {
            storyboard += "-iPad"
        }

        guard let controller = UIStoryboard(name: storyboard, bundle: Bundle(for:object_getClass(self))).instantiateInitialViewController() as? SelectDomainViewController else {
            ❨╯°□°❩╯⌢"Initial ViewController is not of type SelectDomainViewController"
        }

        controller.accountDomainsTableViewController = AccountDomainListViewController()
        controller.selectSessionTableViewController = SelectSessionListViewController.new()
        controller.selectSessionTableViewController.sessionDeleted = { [unowned controller] session in
            controller.roundSeachBarCorners()
        }

        return controller
    }

    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    open override func viewDidLoad() {
        super.viewDidLoad()

        authenticationMethod = .default
        authMethodLabel.textColor = UIColor.white
        selectSessionTableViewController.view.backgroundColor = UIColor.clear
        setupBackgroundView()
        setupSearchTextField()
        setupAccountDomainsView()
        setupMultipleUsersView()
        setupLoginMethodGestureRecognizer()
        setupDismissKeyboardGestureRecognizer()
        setupLogoImageView()
        if useBackButton {
            setupBackButton()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isToolbarHidden = true
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(SelectDomainViewController.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectDomainViewController.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // This must happen once the views are displayed or the mask is set incorrectly
        roundContainerCorners()
        roundSeachBarCorners()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        backgroundView.updateImage(self.traitCollection, coordinator: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.domainSelectionContainerView.layer.mask = nil
            self.multipleUsersContainerView.layer.mask = nil
            self.searchContainerView.layer.mask = nil
        }) { [unowned self] _ in
            self.roundContainerCorners()
            self.roundSeachBarCorners()
        }
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    func setupBackgroundView() {
        backgroundView = self.insertTriangleBackgroundView()
        backgroundView.diagonal = false
        guard let dataSource = dataSource else {
            backgroundView.transitionToColors(.red, tintBottomColor: .orange, duration: 0.0)
            return
        }

        backgroundView.transitionToColors(dataSource.tintTopColor, tintBottomColor: dataSource.tintBottomColor, duration: 0.0)
    }

    func setupSearchTextField() {
        searchTextField.returnKeyType = .go;
        searchTextField.keyboardType = .default;
        searchTextField.autocorrectionType = .no;
        searchTextField.addTarget(self, action: #selector(SelectDomainViewController.updateSearchTerm(_:)), for: .editingChanged)
        searchTextField.delegate = self

        searchTextField.accessibilityIdentifier = "domain_search_field"
        if let searchImage = UIImage(named: "icon_search", in: Bundle(for: SelectDomainViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
            
            var image = searchImage
            
            if #available(iOS 9.0, *) {
                image = image.imageFlippedForRightToLeftLayoutDirection()
            }
            
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 21)
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = UIColor.lightGray
            searchTextField.leftView = imageView
            searchTextField.leftViewMode = .always
        }

        if let prompt = prompt {
            searchTextField.placeholder = prompt
        } else {
            searchTextField.placeholder = NSLocalizedString("Find your school or district", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Domain Picker Search Placeholder")
        }
    }

    func setupAccountDomainsView() {
        accountDomainsTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(accountDomainsTableViewController)
        domainSelectionContainerView.addSubview(accountDomainsTableViewController.view)
        accountDomainsTableViewController.didMove(toParentViewController: self)

        let horizontalAccountsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": accountDomainsTableViewController.view])
        let verticalAccountsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": accountDomainsTableViewController.view])
        domainSelectionContainerView.addConstraints(horizontalAccountsConstraints)
        domainSelectionContainerView.addConstraints(verticalAccountsConstraints)

        setAccountDomainsVisible(false, duration: 0.0)
    }

    func setupMultipleUsersView() {
        selectSessionTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(selectSessionTableViewController)
        multipleUsersContainerView.addSubview(selectSessionTableViewController.view)
        selectSessionTableViewController.didMove(toParentViewController: self)

        let horizontalMultiUserConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": selectSessionTableViewController.view])
        let verticalMultiUserConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": selectSessionTableViewController.view])
        multipleUsersContainerView.addConstraints(horizontalMultiUserConstraints)
        multipleUsersContainerView.addConstraints(verticalMultiUserConstraints)

        setMultipleUserVisible(true, duration: 0.0)
    }

    func setupLoginMethodGestureRecognizer() {
        let loginMethodGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectDomainViewController.switchLoginMethod))
        loginMethodGestureRecognizer.numberOfTapsRequired = 2
        loginMethodGestureRecognizer.numberOfTouchesRequired = 2
        loginMethodGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(loginMethodGestureRecognizer)
    }

    func setupDismissKeyboardGestureRecognizer() {
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectDomainViewController.dismissKeyboard))
        dismissKeyboardGestureRecognizer.delegate = self
        dismissKeyboardGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
    }

    func setupLogoImageView() {
        guard let image = dataSource?.logoImage else {
            logoImageView.image = UIImage(named: "keymaster_logo_image", in: Bundle(for: SelectDomainViewController.self), compatibleWith: traitCollection)
            return
        }

        logoImageView.image = image
    }

    func setupBackButton() {
        let backImage = UIImage.RTLImage("icon_back", renderingMode: .alwaysTemplate)
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(backImage, for: .normal)
        button.setBackgroundImage(backImage, for: .selected)
        button.tintColor = UIColor.white
        button.accessibilityLabel = NSLocalizedString("Back", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Back Button Title")
        button.accessibilityIdentifier = "back_button"

        self.view.addSubview(button)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[subview]", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": button]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[subview]", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": button]))

        button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))

        button.addTarget(self, action: #selector(SelectDomainViewController.backButtonPressed(_:)), for: .touchUpInside)
    }

    // ---------------------------------------------
    // MARK: - Styling
    // ---------------------------------------------
    func roundContainerCorners() {
        domainSelectionContainerView.roundCorners([.bottomRight, .bottomLeft], radius: cornerRadius)
        multipleUsersContainerView.roundCorners([.bottomRight, .bottomLeft], radius: cornerRadius)
    }

    func roundSeachBarCorners() {
        let domainsVisible = self.domainSelectionContainerView.alpha == 1.0 ? true : false
        let sessionsVisible = self.multipleUsersContainerView.alpha == 1.0 ? true : false

        var corners: UIRectCorner = [.topRight, .topLeft, .bottomRight, .bottomLeft]
        var dividerHidden = true
        if domainsVisible && accountDomainsTableViewController.tableView.numberOfRows(inSection: 0) > 0 {
            corners = [.topRight, .topLeft]
            dividerHidden = false
        }

        if allowMultipleUsers && sessionsVisible && selectSessionTableViewController.tableView.numberOfRows(inSection: 0) > 0 {
            corners = [.topRight, .topLeft]
            dividerHidden = false
        }

        searchContainerView.roundCorners(corners, radius: cornerRadius)
        searchDividerView.isHidden = dividerHidden
    }

    // ---------------------------------------------
    // MARK: - IBActions / Gesture Recognizer Methods
    // ---------------------------------------------
    func updateSearchTerm(_ textfield: UITextField) {
        // update the font based on whether or not the textfield is empty
        guard let searchTerm = textfield.text else {
            return
        }
        accountDomainsTableViewController.searchTerm = searchTerm
        roundSeachBarCorners()
    }

    func switchLoginMethod() {
        authenticationMethod = authenticationMethod.nextMethod()
    }

    func dismissKeyboard() {
        if searchTextField.isFirstResponder {
            searchTextField.resignFirstResponder()
        }
    }

    func backButtonPressed(_ sender: UIButton) {
        if let presentor = self.presentingViewController {
            presentor.dismiss(animated: true)
        } else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

    // ---------------------------------------------
    // MARK: - Animations
    // ---------------------------------------------
    func setMultipleUserVisible(_ visible: Bool = true, duration: TimeInterval = defaultKeyboardAnimationDuration, options: UIViewAnimationOptions = SelectDomainViewController.defaultKeyboardAnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [unowned self] () -> Void in
            if !self.allowMultipleUsers {
                self.multipleUsersContainerView.alpha = 0.0
            } else {
                self.multipleUsersContainerView.alpha = visible ? 1.0 : 0.0
            }
            }, completion: nil)
    }

    func setAccountDomainsVisible(_ visible: Bool = true, duration: TimeInterval = defaultKeyboardAnimationDuration, options: UIViewAnimationOptions = SelectDomainViewController.defaultKeyboardAnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [unowned self] () -> Void in
            self.domainSelectionContainerView.alpha = visible ? 1.0 : 0.0
            }, completion: nil)
    }

    func setTextFieldFocusedConstraits(_ focused: Bool, duration: TimeInterval = defaultKeyboardAnimationDuration, options: UIViewAnimationOptions = SelectDomainViewController.defaultKeyboardAnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [unowned self] () -> Void in
            self.searchTextFieldToSuperviewConstraint?.constant = focused ? 20 : 160
            self.view.layoutIfNeeded()
            self.roundContainerCorners()
            self.roundSeachBarCorners()
            }, completion: nil)
    }

    func setKeyboardVisibleConstraints(_ visible: Bool, height: CGFloat = 226.0, duration: TimeInterval = defaultKeyboardAnimationDuration, options: UIViewAnimationOptions = SelectDomainViewController.defaultKeyboardAnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [unowned self] () -> Void in
            self.containerBottomToSuperviewConstraint?.constant = visible ? height : 20
            self.view.layoutIfNeeded()
            self.roundContainerCorners()
            self.roundSeachBarCorners()
            }, completion: nil)
    }

    // ---------------------------------------------
    // MARK: - UINotification Keyboard Handling
    // ---------------------------------------------
    func keyboardWillShowNotification(_ notification: Notification) {
        keyboardIsShowing = true
        let duration = animationDurationFromKeyboardNotification(notification)
        let options = animationOptionsFromKeyboardNotification(notification)
        let keyboardHeight = keyboardHeightFromKeyboardNotification(notification)

        setMultipleUserVisible(false, duration: duration, options: options)
        setAccountDomainsVisible(true, duration: duration, options: options)
        setKeyboardVisibleConstraints(true, height: keyboardHeight, duration: duration, options: options)
    }

    func keyboardWillHideNotification(_ notification: Notification) {
        // Sometimes iOS is stupid.  Apparently if you have an external keyboard attached
        // you will still get a UIKeyboardWillHideNotification notification.  Why?  I don't
        // know.  So we're stuck tracking it ourselves.
        if keyboardIsShowing {
            let duration = animationDurationFromKeyboardNotification(notification)
            let options = animationOptionsFromKeyboardNotification(notification)

            setMultipleUserVisible(true, duration: duration, options: options)
            setAccountDomainsVisible(false, duration: duration, options: options)
            setKeyboardVisibleConstraints(false, duration: duration, options: options)
        }
    }

    func animationDurationFromKeyboardNotification(_ notification: Notification) -> TimeInterval {
        guard let userInfo = notification.userInfo, let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return 0.0
        }

        return animationDuration.doubleValue
    }

    func animationOptionsFromKeyboardNotification(_ notification: Notification) -> UIViewAnimationOptions {
        guard let userInfo = notification.userInfo, let rawCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return []
        }

        let rawAnimationCurve = rawCurve.uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        return [.beginFromCurrentState, animationCurve]
    }

    func keyboardHeightFromKeyboardNotification(_ notification: Notification) -> CGFloat {
        guard let userInfo = notification.userInfo, let rawSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return 0
        }

        let size = rawSize.cgRectValue
        return size.height
    }

    // ---------------------------------------------
    // MARK: - Error Handling
    // ---------------------------------------------
    func presentError(_ error: NSError) {
        let title = NSLocalizedString("Error", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Title for an error popup")
        let message = error.localizedDescription

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "OK Button Title"), style: .default, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }

}

extension SelectDomainViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let accountsLocation = touch.location(in: accountDomainsTableViewController.view)
        var accountsIndexPath: IndexPath? = nil
        if domainSelectionContainerView.alpha == 1.0 {
            accountsIndexPath = accountDomainsTableViewController.tableView.indexPathForRow(at: accountsLocation)
        }
        if let accountsIndexPath = accountsIndexPath, let visibleRows = accountDomainsTableViewController.tableView.indexPathsForVisibleRows {
            print(visibleRows)
            if visibleRows.contains(accountsIndexPath) {
                return false
            }
        }

        let sessionsLocation = touch.location(in: selectSessionTableViewController.view)
        var sessionsIndexPath: IndexPath? = nil
        if multipleUsersContainerView.alpha == 1.0 {
            sessionsIndexPath = selectSessionTableViewController.tableView.indexPathForRow(at: sessionsLocation)
        }
        if let sessionsIndexPath = sessionsIndexPath, let visibleRows = selectSessionTableViewController.tableView.indexPathsForVisibleRows {
            print(visibleRows)
            if visibleRows.contains(sessionsIndexPath) {
                return false
            }
        }
        return true
    }

    func selectDomain(_ response: MobileVerifyResponse) {

        let showError = { (domain: URL?) in
            let stringURL = domain?.absoluteString ?? ""
            let title = NSLocalizedString("Error", comment: "Title for an error popup")
            let message = NSLocalizedString("There was a problem verifying the following domain: \(stringURL)", comment: "Message for an error alert")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let actionTitle = NSLocalizedString("OK", comment: "")
            let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }

        guard let navigationController = self.navigationController, let baseURL = response.baseURL, let clientID = response.clientID, let clientSecret = response.clientSecret else {
            showError(response.baseURL)
            return
        }

        // HELLO!
        // Most of the time, mobileverify returns the https scheme on this url
        // However, there was a bug that was accidently released into production
        // This bug forced us to change how mobile verify works temporarily, by removing the https on mobileverify
        // This code below will ensure that the scheme is on the URL. It should work both ways now with the fix and without the fix on mobileverify
        var pickedURL = baseURL
        let components = URLComponents(url: pickedURL, resolvingAgainstBaseURL: false)
        if let comps = components, comps.scheme == nil {

            if let url = URL(string: "https://\(pickedURL.absoluteString)") {
                pickedURL = url
            }
            else {
                return showError(baseURL)
            }
        }

        pickedDomainAction?(pickedURL, nil)

        if useKeymasterLogin {
            DispatchQueue.main.async(execute: {
                let loginViewController = LoginViewController.new(baseURL, clientID: clientID, clientSecret: clientSecret)
                loginViewController.useBackButton = self.useBackButton
                loginViewController.result = { [weak self] result in
                    if let error = result.error {
                        self?.presentError(error)
                    }

                    if let session = result.value, let pickedSessionAction = self?.pickedSessionAction {
                        pickedSessionAction(session)
                    }
                }
                navigationController.show(loginViewController, sender: self)
            })
        }
    }

}

extension SelectDomainViewController: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setMultipleUserVisible(false)
        setAccountDomainsVisible(true)
        setTextFieldFocusedConstraits(true)

        return true
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        setMultipleUserVisible(true)
        setAccountDomainsVisible(false)
        setTextFieldFocusedConstraits(false)

        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if let text = textField.text {
            var domain = text
            domain.domainify()
            if (useMobileVerify) {
                validateMobileVerify(domain)
            } else {
                domain.addURLScheme()
                guard let url = URL(string: domain) else {

                    let errorDescription = NSLocalizedString("Could not create domain.  Please check your school's domain and try again.", bundle: .parent, comment: "Error alert message")

                    presentError(NSError(domain: "com.instructure.selectdomain", code: 101, userInfo: [ NSLocalizedDescriptionKey:  errorDescription]))
                    return false
                }
                pickedDomainAction?(url, nil)
            }
        }

        return false
    }

}

// ---------------------------------------------
// MARK: - Mobile Verify
// ---------------------------------------------
extension SelectDomainViewController {
    fileprivate func validateMobileVerify(_ domain: String) {
        // Show Loading
        let mobileVerifier = MobileVerifier()
        mobileVerifier.appName = dataSource?.mobileVerifyName ?? ""
        mobileVerifier.mobileVerify(domain, success: { [weak self] response in
            guard response.authorized == true else {
                self?.presentError(MobileVerifyResult.errorForResult(response.result))
                return
            }
            guard response.result == .success else {
                self?.presentError(MobileVerifyResult.errorForResult(response.result))
                return
            }

            self?.selectDomain(response)

        }) { [weak self] error in
            self?.presentError(error)
        }
    }
}
