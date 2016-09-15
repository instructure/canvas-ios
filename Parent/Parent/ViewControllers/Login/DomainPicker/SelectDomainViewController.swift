//
//  SelectDomainViewController.swift
//  Keymaster
//
//  Created by Brandon Pluim on 12/4/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

import SoPretty
import SoLazy

public class SelectDomainViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var authMethodLabel: UILabel!
    
    @IBOutlet weak var domainSelectionContainerView: UIView!
    @IBOutlet weak var multipleUsersContainerView: UIView!
    
    var accountDomainsTableViewController: AccountDomainsTableViewController!
    var multiUserTableViewController: MultiUserTableViewController!
    
    var pickedDomainAction : PickDomainSuccessfulAction = { domain in print("Domain Picked:\t\(domain.name)") }
    var pickedSessionAction : PickUserSuccessfulAction = { session in print("User Picked:\n  AuthToken:\t\(session.auth.token)") }
    
    var authenticationMethod: AuthenticationMethod = .Default
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "SelectDomainViewController"
    public static func new(storyboardName: String = defaultStoryboardName, pickedSessionAction: PickUserSuccessfulAction, pickedDomainAction: PickDomainSuccessfulAction) -> SelectDomainViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass:object_getClass(self))).instantiateInitialViewController() as? SelectDomainViewController else {
            fatalError("Initial ViewController is not of type SelectDomainViewController")
        }
        
        controller.accountDomainsTableViewController = AccountDomainsTableViewController.new(pickedDomainAction: pickedDomainAction)
        controller.multiUserTableViewController = MultiUserTableViewController.new(pickedSessionAction: pickedSessionAction)
        controller.pickedDomainAction = pickedDomainAction
        controller.pickedSessionAction = pickedSessionAction
        
        return controller
    }

    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchTextField()
        setupAccountDomainsView()
        setupMultipleUsersView()
        setupLoginMethodGestureRecognizer()
        setupDismissKeyboardGestureRecognizer()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        stylize()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    func setupSearchTextField() {
        searchTextField.returnKeyType = .Go;
        searchTextField.keyboardType = .Default;
        searchTextField.autocorrectionType = .No;
        
        searchTextField.addTarget(self, action: "updateSearchTerm:", forControlEvents: .EditingChanged)
        searchTextField.delegate = self
        searchTextField.placeholder = NSLocalizedString("", value: "", comment: "")
        searchTextField.accessibilityLabel = NSLocalizedString("", value: "", comment: "")
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
        multiUserTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(multiUserTableViewController)
        multipleUsersContainerView.addSubview(multiUserTableViewController.view)
        multiUserTableViewController.didMoveToParentViewController(self)
        
        let horizontalMultiUserConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": multiUserTableViewController.view])
        let verticalMultiUserConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": multiUserTableViewController.view])
        multipleUsersContainerView.addConstraints(horizontalMultiUserConstraints)
        multipleUsersContainerView.addConstraints(verticalMultiUserConstraints)
        
        setMultipleUserVisible(true, duration: 0.0)
    }
    
    func setupLoginMethodGestureRecognizer() {
        let loginMethodGestureRecognizer = UITapGestureRecognizer(target: self, action: "switchLoginMethod")
        loginMethodGestureRecognizer.numberOfTapsRequired = 2
        loginMethodGestureRecognizer.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(loginMethodGestureRecognizer)
    }
    
    func setupDismissKeyboardGestureRecognizer() {
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        dismissKeyboardGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
    }
    
    func stylize() {
        domainSelectionContainerView.roundCorners([.BottomRight, .BottomLeft], radius: 10.0)
        multipleUsersContainerView.roundCorners([.BottomRight, .BottomLeft], radius: 10.0)
    }
    
    // ---------------------------------------------
    // MARK: - IBActions / Gesture Recognizer Methods
    // ---------------------------------------------
    func updateSearchTerm(textfield: UITextField) {
        // update the font based on whether or not the textfield is empty
        
        accountDomainsTableViewController.searchTerm = textfield.text
    }
    
    func switchLoginMethod() {
        authenticationMethod = authenticationMethod.nextMethod()
    }
    
    func dismissKeyboard() {
        if searchTextField.isFirstResponder() {
            searchTextField.resignFirstResponder()
        }
    }
    
    // ---------------------------------------------
    // MARK: - Animations
    // ---------------------------------------------
    func setMultipleUserVisible(visible: Bool = true, duration: NSTimeInterval = 0.3, options: UIViewAnimationOptions = []) {
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: { () -> Void in
            self.multipleUsersContainerView.alpha = visible ? 1.0 : 0.0
            }, completion: nil)
    }
    
    func setAccountDomainsVisible(visible: Bool = true, duration: NSTimeInterval = 0.3, options: UIViewAnimationOptions = []) {
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: { () -> Void in
            self.domainSelectionContainerView.alpha = visible ? 1.0 : 0.0
            }, completion: nil)
    }
    
    // ---------------------------------------------
    // MARK: - UINotification Keyboard Handling
    // ---------------------------------------------
    func keyboardWillShowNotification(notification: NSNotification) {
        let duration = animationDurationFromKeyboardNotification(notification)
        let options = animationOptionsFromKeyboardNotification(notification)
        
        setMultipleUserVisible(false, duration: duration, options: options)
        setAccountDomainsVisible(true, duration: duration, options: options)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        let duration = animationDurationFromKeyboardNotification(notification)
        let options = animationOptionsFromKeyboardNotification(notification)
        
        setMultipleUserVisible(true, duration: duration, options: options)
        setAccountDomainsVisible(false, duration: duration, options: options)
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
    
    func handleError(error: NSError) {
        
    }
    
}

extension SelectDomainViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        print(touch.view)
        if touch.view == multiUserTableViewController.view || touch.view == accountDomainsTableViewController.view {
            return false
        }
        
        return true
    }
}

extension SelectDomainViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text {
            var domain = text
            domain.domainify()
            validateMobileVerify(domain)
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
//        mobileVerifier.appName = "ios-parental"
        mobileVerifier.appName = "iCanvas"
        mobileVerifier.mobileVerify(domain, success: { response in
            
            print(response)
            print(response.authorized)
            print(response.clientID)
            print(response.clientSecret)
            
            guard response.authorized == true else {
                // Handle Error
                return
            }
            guard response.result == .Success else {
                // Handle Error
                return
            }
            
            let accountDomain = AccountDomain(name: response.baseURL!.absoluteString, domain: response.baseURL!.absoluteString)
            self.pickedDomainAction(accountDomain)
            
            }) { error in
                // TODO: Handle Errors
                print(error)
        }
    }
}

// ---------------------------------------------
// MARK: - Domainify
// ---------------------------------------------
extension String {
    mutating func domainify() {
        stripURLScheme()
        removeSlashes()
        addInstructureDotComIfNeeded()
    }
    
    mutating func stripURLScheme() {
        let schemes = ["http://", "https://"]
        for scheme in schemes {
            if self.hasPrefix(scheme) {
                self = (self as NSString).substringFromIndex(scheme.characters.count)
            }
        }
    }
    
    mutating func removeSlashes() {
        self = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
    }
    
    mutating func addInstructureDotComIfNeeded() {
        if self.rangeOfString(":") == nil && self.rangeOfString(".") == nil {
            self += ".instructure.com"
        }
    }
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}