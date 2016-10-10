//
//  SelectDomainViewController.swift
//  Keymaster
//
//  Created by Brandon Pluim on 12/4/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

import TooLegit
import SoLazy
import SoPretty

public protocol SelectDomainDataSource {
    var logoImage: UIImage { get }
    var mobileVerifyName: String { get }
    var tintTopColor: UIColor { get }
    var tintBottomColor: UIColor { get }
}

public class SelectDomainViewController: UIViewController {

    // ---------------------------------------------
    // MARK: - typealias
    // ---------------------------------------------
    public typealias PickDomainAction = (NSURL) -> ()
    public typealias PickSessionAction = (Session) -> ()

    // ---------------------------------------------
    // MARK: - Keyboard CONSTANTS
    // ---------------------------------------------
    // This is ugly, but it should work consistently.
    private static let defaultKeyboardAnimationDuration: NSTimeInterval = 0.25
    private static let defaultKeyboardAnimationOptions: UIViewAnimationOptions = [.BeginFromCurrentState, UIViewAnimationOptions(rawValue: 458752)]
    private var keyboardIsShowing = false
    private let cornerRadius: CGFloat = 7.0

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
    private var accountDomainsTableViewController: AccountDomainListViewController!
    private var selectSessionTableViewController: SelectSessionListViewController!

    // ---------------------------------------------
    // MARK: - Public Vars
    // ---------------------------------------------
    public var dataSource: SelectDomainDataSource? = nil
    public var allowMultipleUsers = false
    public var useMobileVerify = true
    public var useKeymasterLogin = true
    public var useBackButton = true
    public var prompt: String? = nil

    public var pickedDomainAction : ((NSURL) -> ())? {
        didSet {
            if let _ = pickedDomainAction {
                accountDomainsTableViewController.pickedDomainAction = { [weak self] domain in
                    guard let me = self else { return }
                    me.searchTextField.resignFirstResponder()
                    if (me.useMobileVerify) {
                        me.validateMobileVerify(domain.absoluteString!)
                    } else {
                        print(domain)
                        me.pickedDomainAction?(domain)
                    }
                }
            }
        }
    }

    public var pickedSessionAction : ((Session) -> ())? {
        didSet {
            if let pickedSessionAction = pickedSessionAction {
                selectSessionTableViewController.pickedSessionAction = pickedSessionAction
            }
        }
    }

    var authenticationMethod: AuthenticationMethod = .Default {
        didSet {
            authMethodLabel.text = authenticationMethod.displayText()
        }
    }

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "SelectDomainViewController"
    public static func new(storyboardName: String = defaultStoryboardName) -> SelectDomainViewController {
        var storyboard = storyboardName
        if storyboardName == defaultStoryboardName && UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            storyboard += "-iPad"
        }

        guard let controller = UIStoryboard(name: storyboard, bundle: NSBundle(forClass:object_getClass(self))).instantiateInitialViewController() as? SelectDomainViewController else {
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
    public override func viewDidLoad() {
        super.viewDidLoad()

        authenticationMethod = .Default
        authMethodLabel.textColor = UIColor.whiteColor()
        selectSessionTableViewController.view.backgroundColor = UIColor.clearColor()
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

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.toolbarHidden = true
        self.navigationController?.navigationBarHidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SelectDomainViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SelectDomainViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // This must happen once the views are displayed or the mask is set incorrectly
        roundContainerCorners()
        roundSeachBarCorners()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    public override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        backgroundView.updateImage(self.traitCollection, coordinator: coordinator)
        coordinator.animateAlongsideTransition({ [unowned self] _ in
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
            backgroundView.transitionToColors(UIColor.redColor(), tintBottomColor: UIColor.orangeColor(), duration: 0.0)
            return
        }

        backgroundView.transitionToColors(dataSource.tintTopColor, tintBottomColor: dataSource.tintBottomColor, duration: 0.0)
    }

    func setupSearchTextField() {
        searchTextField.returnKeyType = .Go;
        searchTextField.keyboardType = .Default;
        searchTextField.autocorrectionType = .No;

        searchTextField.addTarget(self, action: #selector(SelectDomainViewController.updateSearchTerm(_:)), forControlEvents: .EditingChanged)
        searchTextField.delegate = self

        searchTextField.accessibilityIdentifier = "domain_search_field"
        if let searchImage = UIImage(named: "icon_search", inBundle: NSBundle(forClass: SelectDomainViewController.self), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate) {
            let imageView = UIImageView(image: searchImage)
            imageView.frame = CGRectMake(0, 0, 40, 21)
            imageView.contentMode = .ScaleAspectFit
            imageView.tintColor = UIColor.lightGrayColor()
            searchTextField.leftView = imageView
            searchTextField.leftViewMode = .Always
        }

        if let prompt = prompt {
            searchTextField.placeholder = prompt
        } else {
            searchTextField.placeholder = NSLocalizedString("Find your school or district", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "Domain Picker Search Placeholder")
        }
    }

    func setupAccountDomainsView() {
        accountDomainsTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(accountDomainsTableViewController)
        domainSelectionContainerView.addSubview(accountDomainsTableViewController.view)
        accountDomainsTableViewController.didMoveToParentViewController(self)

        let horizontalAccountsConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": accountDomainsTableViewController.view])
        let verticalAccountsConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": accountDomainsTableViewController.view])
        domainSelectionContainerView.addConstraints(horizontalAccountsConstraints)
        domainSelectionContainerView.addConstraints(verticalAccountsConstraints)

        setAccountDomainsVisible(false, duration: 0.0)
    }

    func setupMultipleUsersView() {
        selectSessionTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(selectSessionTableViewController)
        multipleUsersContainerView.addSubview(selectSessionTableViewController.view)
        selectSessionTableViewController.didMoveToParentViewController(self)

        let horizontalMultiUserConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": selectSessionTableViewController.view])
        let verticalMultiUserConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": selectSessionTableViewController.view])
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
            logoImageView.image = UIImage(named: "keymaster_logo_image", inBundle: NSBundle(forClass: SelectDomainViewController.self), compatibleWithTraitCollection: traitCollection)
            return
        }

        logoImageView.image = image
    }

    func setupBackButton() {
        let backImage = UIImage(named: "icon_back")?.imageWithRenderingMode(.AlwaysTemplate)
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(backImage, forState: .Normal)
        button.setBackgroundImage(backImage, forState: .Selected)
        button.tintColor = UIColor.whiteColor()
        button.accessibilityLabel = NSLocalizedString("Back", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "Back Button Title")
        button.accessibilityIdentifier = "back_button"

        self.view.addSubview(button)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[subview]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": button]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[subview]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": button]))

        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))

        button.addTarget(self, action: #selector(SelectDomainViewController.backButtonPressed(_:)), forControlEvents: .TouchUpInside)
    }

    // ---------------------------------------------
    // MARK: - Styling
    // ---------------------------------------------
    func roundContainerCorners() {
        domainSelectionContainerView.roundCorners([.BottomRight, .BottomLeft], radius: cornerRadius)
        multipleUsersContainerView.roundCorners([.BottomRight, .BottomLeft], radius: cornerRadius)
    }

    func roundSeachBarCorners() {
        let domainsVisible = self.domainSelectionContainerView.alpha == 1.0 ? true : false
        let sessionsVisible = self.multipleUsersContainerView.alpha == 1.0 ? true : false

        var corners: UIRectCorner = [.TopRight, .TopLeft, .BottomRight, .BottomLeft]
        var dividerHidden = true
        if domainsVisible && accountDomainsTableViewController.tableView.numberOfRowsInSection(0) > 0 {
            corners = [.TopRight, .TopLeft]
            dividerHidden = false
        }

        if allowMultipleUsers && sessionsVisible && selectSessionTableViewController.tableView.numberOfRowsInSection(0) > 0 {
            corners = [.TopRight, .TopLeft]
            dividerHidden = false
        }

        searchContainerView.roundCorners(corners, radius: cornerRadius)
        searchDividerView.hidden = dividerHidden
    }

    // ---------------------------------------------
    // MARK: - IBActions / Gesture Recognizer Methods
    // ---------------------------------------------
    func updateSearchTerm(textfield: UITextField) {
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
        if searchTextField.isFirstResponder() {
            searchTextField.resignFirstResponder()
        }
    }

    func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    // ---------------------------------------------
    // MARK: - Animations
    // ---------------------------------------------
    func setMultipleUserVisible(visible: Bool = true, duration: NSTimeInterval = defaultKeyboardAnimationDuration, options: UIViewAnimationOptions = SelectDomainViewController.defaultKeyboardAnimationOptions) {
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: { [unowned self] () -> Void in
            if !self.allowMultipleUsers {
                self.multipleUsersContainerView.alpha = 0.0
            } else {
                self.multipleUsersContainerView.alpha = visible ? 1.0 : 0.0
            }
            }, completion: nil)
    }

    func setAccountDomainsVisible(visible: Bool = true, duration: NSTimeInterval = defaultKeyboardAnimationDuration, options: UIViewAnimationOptions = SelectDomainViewController.defaultKeyboardAnimationOptions) {
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: { [unowned self] () -> Void in
            self.domainSelectionContainerView.alpha = visible ? 1.0 : 0.0
            }, completion: nil)
    }

    func setTextFieldFocusedConstraits(focused: Bool, duration: NSTimeInterval = defaultKeyboardAnimationDuration, options: UIViewAnimationOptions = SelectDomainViewController.defaultKeyboardAnimationOptions) {
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: { [unowned self] () -> Void in
            self.searchTextFieldToSuperviewConstraint?.constant = focused ? 20 : 160
            self.view.layoutIfNeeded()
            self.roundContainerCorners()
            self.roundSeachBarCorners()
            }, completion: nil)
    }

    func setKeyboardVisibleConstraints(visible: Bool, height: CGFloat = 226.0, duration: NSTimeInterval = defaultKeyboardAnimationDuration, options: UIViewAnimationOptions = SelectDomainViewController.defaultKeyboardAnimationOptions) {
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: { [unowned self] () -> Void in
            self.containerBottomToSuperviewConstraint?.constant = visible ? height : 20
            self.view.layoutIfNeeded()
            self.roundContainerCorners()
            self.roundSeachBarCorners()
            }, completion: nil)
    }

    // ---------------------------------------------
    // MARK: - UINotification Keyboard Handling
    // ---------------------------------------------
    func keyboardWillShowNotification(notification: NSNotification) {
        keyboardIsShowing = true
        let duration = animationDurationFromKeyboardNotification(notification)
        let options = animationOptionsFromKeyboardNotification(notification)
        let keyboardHeight = keyboardHeightFromKeyboardNotification(notification)

        setMultipleUserVisible(false, duration: duration, options: options)
        setAccountDomainsVisible(true, duration: duration, options: options)
        setKeyboardVisibleConstraints(true, height: keyboardHeight, duration: duration, options: options)
    }

    func keyboardWillHideNotification(notification: NSNotification) {
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

    func animationDurationFromKeyboardNotification(notification: NSNotification) -> NSTimeInterval {
        guard let userInfo = notification.userInfo, animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return 0.0
        }

        return animationDuration.doubleValue
    }

    func animationOptionsFromKeyboardNotification(notification: NSNotification) -> UIViewAnimationOptions {
        guard let userInfo = notification.userInfo, rawCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return []
        }

        let rawAnimationCurve = rawCurve.unsignedIntValue << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        return [.BeginFromCurrentState, animationCurve]
    }

    func keyboardHeightFromKeyboardNotification(notification: NSNotification) -> CGFloat {
        guard let userInfo = notification.userInfo, rawSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return 0
        }

        let size = rawSize.CGRectValue()
        return size.height
    }

    // ---------------------------------------------
    // MARK: - Error Handling
    // ---------------------------------------------
    func presentError(error: NSError) {
        let title = NSLocalizedString("Error", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "Error Alert Title")
        let message = error.localizedDescription

        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "OK"), style: .Default, handler: { _ in
        }))

        presentViewController(alert, animated: true, completion: nil)
    }

}

extension SelectDomainViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let accountsLocation = touch.locationInView(accountDomainsTableViewController.view)
        var accountsIndexPath: NSIndexPath? = nil
        if domainSelectionContainerView.alpha == 1.0 {
            accountsIndexPath = accountDomainsTableViewController.tableView.indexPathForRowAtPoint(accountsLocation)
        }
        if let accountsIndexPath = accountsIndexPath, visibleRows = accountDomainsTableViewController.tableView.indexPathsForVisibleRows {
            print(visibleRows)
            if visibleRows.contains(accountsIndexPath) {
                return false
            }
        }

        let sessionsLocation = touch.locationInView(selectSessionTableViewController.view)
        var sessionsIndexPath: NSIndexPath? = nil
        if multipleUsersContainerView.alpha == 1.0 {
            sessionsIndexPath = selectSessionTableViewController.tableView.indexPathForRowAtPoint(sessionsLocation)
        }
        if let sessionsIndexPath = sessionsIndexPath, visibleRows = selectSessionTableViewController.tableView.indexPathsForVisibleRows {
            print(visibleRows)
            if visibleRows.contains(sessionsIndexPath) {
                return false
            }
        }
        return true
    }

    func selectDomain(response: MobileVerifyResponse) {

        guard let navigationController = self.navigationController, baseURL = response.baseURL, clientID = response.clientID, clientSecret = response.clientSecret else {
            return
        }

        pickedDomainAction?(baseURL)

        if useKeymasterLogin {
            dispatch_async(dispatch_get_main_queue(), {
                let loginViewController = LoginViewController.new(baseURL: baseURL, clientID: clientID, clientSecret: clientSecret)
                loginViewController.useBackButton = self.useBackButton
                loginViewController.result = { [weak self] result in
                    if let error = result.error {
                        self?.presentError(error)
                    }

                    if let session = result.value, pickedSessionAction = self?.pickedSessionAction {
                        pickedSessionAction(session)
                    }
                }
                navigationController.showViewController(loginViewController, sender: self)
            })
        }
    }

}

extension SelectDomainViewController: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        setMultipleUserVisible(false)
        setAccountDomainsVisible(true)
        setTextFieldFocusedConstraits(true)

        return true
    }

    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        setMultipleUserVisible(true)
        setAccountDomainsVisible(false)
        setTextFieldFocusedConstraits(false)

        return true
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if let text = textField.text {
            var domain = text
            domain.domainify()
            if (useMobileVerify) {
                validateMobileVerify(domain)
            } else {
                domain.addURLScheme()
                guard let url = NSURL(string: domain) else {
                    presentError(NSError(domain: "com.instructure.selectdomain", code: 101, userInfo: [ NSLocalizedDescriptionKey: "Could not create domain.  Please check your school's domain and try again." ]))
                    return false
                }
                pickedDomainAction?(url)
            }
        }

        return false
    }

}

// ---------------------------------------------
// MARK: - Mobile Verify
// ---------------------------------------------
extension SelectDomainViewController {
    private func validateMobileVerify(domain: String) {
        // Show Loading
        let mobileVerifier = MobileVerifier()
        mobileVerifier.appName = dataSource?.mobileVerifyName ?? ""
        mobileVerifier.mobileVerify(domain, success: { [weak self] response in
            guard response.authorized == true else {
                self?.presentError(MobileVerifyResult.errorForResult(response.result))
                return
            }
            guard response.result == .Success else {
                self?.presentError(MobileVerifyResult.errorForResult(response.result))
                return
            }
            
            self?.selectDomain(response)
            
        }) { [weak self] error in
            self?.presentError(error)
        }
    }
}
