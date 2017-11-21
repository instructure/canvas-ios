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

import Result

import WebKit
import CanvasCore
import Marshal

public typealias UIButtonAction = (UIButton) -> ()
public typealias ChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> ()

public enum AuthenticationMethod: Int {
    case `default`
    case forced
    case siteAdmin

    func nextMethod() -> AuthenticationMethod {
        let newRaw = self.rawValue + 1
        guard let auth = AuthenticationMethod(rawValue: newRaw) else {
            return .default
        }

        return auth
    }

    func displayText() -> String {
        switch(self) {
        case .default:
            return " "
        case .forced:
            return "Canvas Login"
        case .siteAdmin:
            return "Site Admin"
        }
    }
}


public enum AuthenticationErrorCode: Int {
    case cancelled = 1000
    case accessDenied = 1001
    case incorrectJSON = 1002

    func error() -> NSError {
        switch (self) {
        case .cancelled:
            return NSError(domain: "com.instructure.login", code: AuthenticationErrorCode.cancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "Authentication failed. User cancelled authentication."])
        case .accessDenied:
            return NSError(domain: "com.instructure.login", code: AuthenticationErrorCode.accessDenied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Authentication failed. User denied the request for access."])
        case .incorrectJSON:
            return NSError(domain: "com.instructure.login", code: AuthenticationErrorCode.incorrectJSON.rawValue, userInfo: [NSLocalizedDescriptionKey: "OAuthJSON Incorrect. Check the server response"])
        }
    }
}

open class LoginViewController: UIViewController {

    public typealias LoginResult = (Result<Session, NSError>) -> ()

    // ---------------------------------------------
    // MARK: - Instance Vars
    // ---------------------------------------------
    @IBOutlet var webview: UIWebView!
    var backButton: UIButton!

    // privates
    fileprivate let authMethod = AuthenticationMethod.default
    fileprivate var challengeHandler: ChallengeHandler?
    fileprivate var clientID: String?
    fileprivate var clientSecret: String?
    fileprivate var baseURL: URL?
    fileprivate var loginOAuthURL: URL?

    fileprivate var session: Foundation.URLSession?

    // ---------------------------------------------
    // MARK: - External Actions
    // ---------------------------------------------
    open var result: LoginResult?
    open var createAccountAction: UIButtonAction?
    open var forgotPasswordAction: UIButtonAction?
    open var useBackButton = false

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    fileprivate static let defaultStoryboardName = "LoginViewController"
    open static func new(_ baseURL: URL, clientID: String, clientSecret: String) -> LoginViewController {
        guard let controller = UIStoryboard(name: defaultStoryboardName, bundle: Bundle(for: self)).instantiateInitialViewController() as? LoginViewController else {
            ❨╯°□°❩╯⌢"Initial ViewController is not of type LoginViewController"
        }

        controller.clientID = clientID
        controller.clientSecret = clientSecret
        controller.baseURL = baseURL
        controller.loginOAuthURL = controller.canvasLoginOAuthURL(baseURL, clientID: clientID)

        let config = URLSessionConfiguration.default
        controller.session = Foundation.URLSession(configuration: config, delegate: controller, delegateQueue: nil)

        return controller
    }

    // ---------------------------------------------
    // MARK: - UIViewController Lifecycle
    // ---------------------------------------------
    override open func viewDidLoad() {
        super.viewDidLoad()

        // remove existing cookies
        clearExistingCookiess()

        // Start the request
        startLoginRequest()
        setupBackButton()
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // --------------------------------------------
    func setupBackButton() {
        if let navController = self.navigationController, !navController.isNavigationBarHidden {
            return
        }

        let backImage = UIImage(named: "icon_back")?.withRenderingMode(.alwaysTemplate)
        backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setBackgroundImage(backImage, for: UIControlState())
        backButton.setBackgroundImage(backImage, for: .selected)
        backButton.tintColor = UIColor.white

        self.view.addSubview(backButton)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[subview]", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": backButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[subview]", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": backButton]))

        backButton.addConstraint(NSLayoutConstraint(item: backButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
        backButton.addConstraint(NSLayoutConstraint(item: backButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))

        backButton.addTarget(self, action: #selector(LoginViewController.backButtonPressed(_:)), for: .touchUpInside)

        updateBackButton()
    }

    // ---------------------------------------------
    // MARK: - UI Methods
    // ---------------------------------------------
    fileprivate func showUserPasswordAlert() {

        let alertController = UIAlertController(title: "Login", message: "Please login using your site admin credentials", preferredStyle: .alert)

        let loginAction = UIAlertAction(title: "Login", style: .default) { _ in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField

            if let username = loginTextField.text, let password = passwordTextField.text {
                self.login(username, password: password)
            }
        }
        loginAction.isEnabled = false

        alertController.addTextField { (textField) in
            textField.placeholder = "Username"

            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                loginAction.isEnabled = textField.text != ""
            }
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { action in
            self.cancelOAuth()
        }

        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true) { }
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction fileprivate func createAccountButtonPressed(_ sender: UIButton) {
        createAccountAction?(sender)
    }

    @IBAction fileprivate func forgotPasswordButtonPressed(_ sender: UIButton) {
        forgotPasswordAction?(sender)
    }

    func backButtonPressed(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    func updateBackButton() {
        backButton.isHidden = !useBackButton
    }

    // ---------------------------------------------
    // MARK: - Private Methods
    // ---------------------------------------------
    fileprivate func clearExistingCookiess() {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
    }

    fileprivate func startLoginRequest() {

        guard let url = loginOAuthURL else {
            ❨╯°□°❩╯⌢"Request cannot be created from the baseURL and client_id provided"
        }

        let request = URLRequest(url: url)
        webview.loadRequest(request)

        session?.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async(execute: {
                self.loadLoginRequest()
            })
        }) .resume()
    }

    fileprivate func loadLoginRequest() {
        guard let url = loginOAuthURL else {
            ❨╯°□°❩╯⌢"Request cannot be created from the baseURL and client_id provided"
        }

        if let request = (URLRequest(url: url) as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
            if authMethod == .siteAdmin {
                request.httpShouldHandleCookies = true
                let cookieProperties = [
                    HTTPCookiePropertyKey.value: "1",
                    HTTPCookiePropertyKey.domain: request.url!.host!,
                    HTTPCookiePropertyKey.name: "canvas_sa_delegated",
                    HTTPCookiePropertyKey.path: "/"
                ]

                let cookie = HTTPCookie(properties: cookieProperties)!
                HTTPCookieStorage.shared.setCookie(cookie)
                self.webview.loadRequest(request as URLRequest)
            }
        }
    }

    fileprivate func login(_ username: String, password: String) {
        let secretHandshake = URLCredential(user: username, password: password, persistence: .forSession)
        challengeHandler?(.useCredential, secretHandshake)
    }

    func canvasLoginOAuthURL(_ baseURL: URL?, clientID: String?) -> URL? {
        guard let baseURL = baseURL, let clientID = clientID else {
            return nil
        }


        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = "/login/oauth2/auth"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: "urn:ietf:wg:oauth:2.0:oob"),
            URLQueryItem(name: "mobile", value: "1")
        ]

        return urlComponents.url
    }

    // ---------------------------------------------
    // MARK: - Public Methods
    // ---------------------------------------------
    open func cancelOAuth() {
        self.result?(Result(error: AuthenticationErrorCode.cancelled.error()))
    }

    fileprivate func getOAuthTokenFromCode(_ code: String) {
        guard let baseURL = baseURL, let clientID = clientID, let clientSecret = clientSecret else {
            return
        }

        let url = baseURL.appendingPathComponent("login/oauth2/token")

        let parameters = [
            "client_id" : clientID,
            "client_secret" : clientSecret,
            "code" : code
        ]
        var request = try! URLRequest(method: .POST, URL: url, parameters: parameters as [String : AnyObject], encoding: .json)
        request.setValue("close", forHTTPHeaderField: "Connection:")
        Session.unauthenticated.JSONSignalProducer(request).start { event in
            switch event {
            case .value(let json):
                guard let authToken = OAuthToken.fromJSON(json), let baseURL = self.baseURL else {
                    self.result?(Result(error: AuthenticationErrorCode.incorrectJSON.error()))
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
extension LoginViewController : URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        DispatchQueue.main.async(execute: {
            self.challengeHandler = completionHandler

            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
                // Show alert View
                self.showUserPasswordAlert()
            } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                var credential: URLCredential? = nil
                if let trust = challenge.protectionSpace.serverTrust {
                    credential = URLCredential(trust: trust)
                }

                self.challengeHandler?(.useCredential, credential)
            } else {
                self.challengeHandler?(.performDefaultHandling, nil)
            }
        })
    }
}

// ---------------------------------------------
// MARK: - UIWebViewDelegate
// ---------------------------------------------
extension LoginViewController : UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            if url.description == "about.blank" {
                return false
            }

            // We have to wait for the code to be the first param cuz it can keep changing as we follow redirects
            if url.absoluteString.contains("/login/oauth2/auth?code=") {
                if let code = request.url?.queryItemForKey("code")?.value {
                    getOAuthTokenFromCode(code)
                    return false
                }
            } else if request.url?.queryItemForKey("error") != nil {
                self.result?(Result(error: AuthenticationErrorCode.accessDenied.error()))
                return false
            }

        }
        return true
    }
}

public extension URL {

    var allQueryItems: [URLQueryItem] {
        get {
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
            if let allQueryItems = components.queryItems {
                return allQueryItems as [URLQueryItem]
            } else {
                return [URLQueryItem]()
            }
        }
    }
    
    func queryItemForKey(_ key: String) -> URLQueryItem? {
        let predicate = NSPredicate(format: "name=%@", key)
        return (allQueryItems as NSArray).filtered(using: predicate).first as? URLQueryItem
        
    }
}
