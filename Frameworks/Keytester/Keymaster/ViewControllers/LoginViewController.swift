//
//  LoginWebViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 11/13/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import UIKit

import Result
import TooLegit
import WebKit
import SoLazy
import Marshal

public typealias UIButtonAction = (UIButton) -> ()
public typealias ChallengeHandler = (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> ()

public enum AuthenticationMethod: Int {
    case Default
    case Forced
    case SiteAdmin

    func nextMethod() -> AuthenticationMethod {
        let newRaw = self.rawValue + 1
        guard let auth = AuthenticationMethod(rawValue: newRaw) else {
            return .Default
        }

        return auth
    }

    func displayText() -> String {
        switch(self) {
        case .Default:
            return " "
        case .Forced:
            return "Canvas Login"
        case .SiteAdmin:
            return "Site Admin"
        }
    }
}


public enum AuthenticationErrorCode: Int {
    case Cancelled = 1000
    case AccessDenied = 1001
    case IncorrectJSON = 1002

    func error() -> NSError {
        switch (self) {
        case .Cancelled:
            return NSError(domain: "com.instructure.login", code: AuthenticationErrorCode.Cancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "Authentication failed. User cancelled authentication."])
        case .AccessDenied:
            return NSError(domain: "com.instructure.login", code: AuthenticationErrorCode.AccessDenied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Authentication failed. User denied the request for access."])
        case .IncorrectJSON:
            return NSError(domain: "com.instructure.login", code: AuthenticationErrorCode.IncorrectJSON.rawValue, userInfo: [NSLocalizedDescriptionKey: "OAuthJSON Incorrect. Check the server response"])
        }
    }
}

public class LoginViewController: UIViewController {

    public typealias LoginResult = (Result<Session, NSError>) -> ()

    // ---------------------------------------------
    // MARK: - Instance Vars
    // ---------------------------------------------
    @IBOutlet var webview: UIWebView!
    var backButton: UIButton!

    // privates
    private let authMethod = AuthenticationMethod.Default
    private var challengeHandler: ChallengeHandler?
    private var clientID: String?
    private var clientSecret: String?
    private var baseURL: NSURL?
    private var loginOAuthURL: NSURL?

    private var session: NSURLSession?

    // ---------------------------------------------
    // MARK: - External Actions
    // ---------------------------------------------
    public var result: LoginResult?
    public var createAccountAction: UIButtonAction?
    public var forgotPasswordAction: UIButtonAction?
    public var useBackButton = false

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "LoginViewController"
    public static func new(storyboardName: String = defaultStoryboardName, baseURL: NSURL, clientID: String, clientSecret: String) -> LoginViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? LoginViewController else {
            ❨╯°□°❩╯⌢"Initial ViewController is not of type LoginViewController"
        }

        controller.clientID = clientID
        controller.clientSecret = clientSecret
        controller.baseURL = baseURL
        controller.loginOAuthURL = controller.loginOAuthURL(baseURL, clientID: clientID)

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        controller.session = NSURLSession(configuration: config, delegate: controller, delegateQueue: nil)

        return controller
    }

    // ---------------------------------------------
    // MARK: - UIViewController Lifecycle
    // ---------------------------------------------
    override public func viewDidLoad() {
        super.viewDidLoad()

        // remove existing cookies
        clearExistingCookiess()

        // Start the request
        startLoginRequest()
        setupBackButton()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // --------------------------------------------
    func setupBackButton() {
        if let navController = self.navigationController where !navController.navigationBarHidden {
            return
        }

        let backImage = UIImage(named: "icon_back")?.imageWithRenderingMode(.AlwaysTemplate)
        backButton = UIButton(type: .Custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setBackgroundImage(backImage, forState: .Normal)
        backButton.setBackgroundImage(backImage, forState: .Selected)
        backButton.tintColor = UIColor.whiteColor()

        self.view.addSubview(backButton)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[subview]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": backButton]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[subview]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": backButton]))

        backButton.addConstraint(NSLayoutConstraint(item: backButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
        backButton.addConstraint(NSLayoutConstraint(item: backButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))

        backButton.addTarget(self, action: #selector(LoginViewController.backButtonPressed(_:)), forControlEvents: .TouchUpInside)

        updateBackButton()
    }

    // ---------------------------------------------
    // MARK: - UI Methods
    // ---------------------------------------------
    private func showUserPasswordAlert() {

        let alertController = UIAlertController(title: "Login", message: "Please login using your site admin credentials", preferredStyle: .Alert)

        let loginAction = UIAlertAction(title: "Login", style: .Default) { _ in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField

            if let username = loginTextField.text, let password = passwordTextField.text {
                self.login(username, password: password)
            }
        }
        loginAction.enabled = false

        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Username"

            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                loginAction.enabled = textField.text != ""
            }
        }

        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { action in
            self.cancelOAuth()
        }

        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)

        presentViewController(alertController, animated: true) { }
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction private func createAccountButtonPressed(sender: UIButton) {
        createAccountAction?(sender)
    }

    @IBAction private func forgotPasswordButtonPressed(sender: UIButton) {
        forgotPasswordAction?(sender)
    }

    func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func updateBackButton() {
        backButton.hidden = !useBackButton
    }

    // ---------------------------------------------
    // MARK: - Private Methods
    // ---------------------------------------------
    private func clearExistingCookiess() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
    }

    private func startLoginRequest() {

        print(loginOAuthURL(baseURL, clientID: clientID))
        guard let url = loginOAuthURL(baseURL, clientID: clientID) else {
            ❨╯°□°❩╯⌢"Request cannot be created from the baseURL and client_id provided"
        }

        let request = NSURLRequest(URL: url)
        webview.loadRequest(request)

        session?.dataTaskWithRequest(request) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.loadLoginRequest()
            })
        }.resume()
    }

    private func loadLoginRequest() {
        guard let url = loginOAuthURL(baseURL, clientID: clientID) else {
            ❨╯°□°❩╯⌢"Request cannot be created from the baseURL and client_id provided"
        }

        if let request = NSURLRequest(URL: url).mutableCopy() as? NSMutableURLRequest {
            if authMethod == .SiteAdmin {
                request.HTTPShouldHandleCookies = true
                let cookieProperties = [
                    NSHTTPCookieValue: "1",
                    NSHTTPCookieDomain: request.URL!.host!,
                    NSHTTPCookieName: "canvas_sa_delegated",
                    NSHTTPCookiePath: "/"
                ]

                let cookie = NSHTTPCookie(properties: cookieProperties)!
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
                self.webview.loadRequest(request)
            }
        }
    }

    private func login(username: String, password: String) {
        let secretHandshake = NSURLCredential(user: username, password: password, persistence: .ForSession)
        challengeHandler?(.UseCredential, secretHandshake)
    }

    func loginOAuthURL(baseURL: NSURL?, clientID: String?) -> NSURL? {
        guard let baseURL = baseURL, let clientID = clientID else {
            return nil
        }


        let urlComponents = NSURLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = "/login/oauth2/auth"
        urlComponents.queryItems = [
            NSURLQueryItem(name: "client_id", value: clientID),
            NSURLQueryItem(name: "response_type", value: "code"),
            NSURLQueryItem(name: "redirect_uri", value: "urn:ietf:wg:oauth:2.0:oob"),
            NSURLQueryItem(name: "mobile", value: "1")
        ]

        return urlComponents.URL
    }

    // ---------------------------------------------
    // MARK: - Public Methods
    // ---------------------------------------------
    public func cancelOAuth() {
        self.result?(Result(error: AuthenticationErrorCode.Cancelled.error()))
    }

    private func getOAuthTokenFromCode(code: String) {
        guard let baseURL = baseURL, let clientID = clientID, let clientSecret = clientSecret else {
            return
        }

        let url = baseURL.URLByAppendingPathComponent("login/oauth2/token")

        let parameters = [
            "client_id" : clientID,
            "client_secret" : clientSecret,
            "code" : code
        ]
        let request = try! NSMutableURLRequest(method: .POST, URL: url!, parameters: parameters, encoding: .JSON)
        request.setValue("close", forHTTPHeaderField: "Connection:")
        Session.unauthenticated.JSONSignalProducer(request).start { event in
            switch event {
            case .Next(let json):
                guard let authToken = OAuthToken.fromJSON(json), let baseURL = self.baseURL else {
                    self.result?(Result(error: AuthenticationErrorCode.IncorrectJSON.error()))
                    break
                }

                let user = SessionUser(id: "\(authToken.userID)", name: authToken.userName)
                let session = Session(baseURL: baseURL, user: user, token: authToken.accessToken)
                self.result?(Result(value: session))
            default:
                break
            }
        }
    }
}


// ---------------------------------------------
// MARK: - NSURLSessionDelegate
// ---------------------------------------------
extension LoginViewController : NSURLSessionDelegate {
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        dispatch_async(dispatch_get_main_queue(), {
            self.challengeHandler = completionHandler

            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
                // Show alert View
                self.showUserPasswordAlert()
            } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                var credential: NSURLCredential? = nil
                if let trust = challenge.protectionSpace.serverTrust {
                    credential = NSURLCredential(trust: trust)
                }

                self.challengeHandler?(.UseCredential, credential)
            } else {
                self.challengeHandler?(.PerformDefaultHandling, nil)
            }
        })
    }
}

// ---------------------------------------------
// MARK: - UIWebViewDelegate
// ---------------------------------------------
extension LoginViewController : UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL {
            if url.description == "about.blank" {
                return false
            }

            // We have to wait for the code to be the first param cuz it can keep changing as we follow redirects
            if url.absoluteString!.containsString("/login/oauth2/auth?code=") {
                if let code = request.URL?.queryItemForKey("code")?.value {
                    getOAuthTokenFromCode(code)
                    return false
                }
            } else if request.URL?.queryItemForKey("error") != nil {
                self.result?(Result(error: AuthenticationErrorCode.AccessDenied.error()))
                return false
            }

        }
        return true
    }
}

public extension NSURL {

    var allQueryItems: [NSURLQueryItem] {
        get {
            let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)!
            if let allQueryItems = components.queryItems {
                return allQueryItems as [NSURLQueryItem]
            } else {
                return [NSURLQueryItem]()
            }
        }
    }
    
    func queryItemForKey(key: String) -> NSURLQueryItem? {
        let predicate = NSPredicate(format: "name=%@", key)
        return (allQueryItems as NSArray).filteredArrayUsingPredicate(predicate).first as? NSURLQueryItem
        
    }
}
