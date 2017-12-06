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
import CanvasCore





class WebLoginViewController: UIViewController {
    
    let request: URLRequest?
    let loginFailureMessage: String
    var prompt: String? = nil
    
    let promptLabel = UILabel()
    let promptHeader = UIView()
    let stack = UIStackView()
    
    let webView = UIWebView()
    fileprivate let backButton = UIButton(type: .custom)
    
    init(request: URLRequest?, loginFailureMessage: String) {
        self.request = request
        self.loginFailureMessage = loginFailureMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = NSLocalizedString("Log In", comment: "")
        clearExistingCookies()
        setupWebView()
        startLoginRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        promptLabel.text = prompt
        promptHeader.isHidden = prompt == nil || "" == prompt
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func clearExistingCookies() {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
        UserDefaults.standard.synchronize()
    }
    
    func setupWebView() {
        [webView, stack, promptLabel, promptHeader].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        promptLabel.textColor = .white
        promptLabel.textAlignment = .center
        promptLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        promptHeader.addSubview(promptLabel)
        promptHeader.backgroundColor = #colorLiteral(red: 0.005312265363, green: 0.5554948449, blue: 0.8883267045, alpha: 1)
        promptHeader.addSubview(promptLabel)
        
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.isOpaque = false
        
        stack.axis = .vertical
        stack.distribution = .fill
        stack.addArrangedSubview(promptHeader)
        stack.addArrangedSubview(webView)

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            topLayoutGuide.bottomAnchor.constraint(equalTo: stack.topAnchor),
            view.leftAnchor.constraint(equalTo: stack.leftAnchor),
            view.rightAnchor.constraint(equalTo: stack.rightAnchor),
            bottomLayoutGuide.topAnchor.constraint(equalTo: stack.bottomAnchor),
            
            promptLabel.centerXAnchor.constraint(equalTo: promptHeader.centerXAnchor),
            promptLabel.centerYAnchor.constraint(equalTo: promptHeader.centerYAnchor),
            promptLabel.leadingAnchor.constraint(greaterThanOrEqualTo: promptHeader.leadingAnchor),
            promptLabel.trailingAnchor.constraint(lessThanOrEqualTo: promptHeader.trailingAnchor),
            promptLabel.topAnchor.constraint(equalTo: promptHeader.topAnchor, constant: 4),
            promptLabel.bottomAnchor.constraint(equalTo: promptHeader.bottomAnchor, constant: -4),
        ])
    }
    
    func startLoginRequest() {
        if let request = self.request {
            webView.loadRequest(request)
        }
    }
    
    func presentUnexpectedAuthError() {
        let alertController = UIAlertController(title: NSLocalizedString("Authorization Failed.", comment: "Authorization Failed Title"), message: loginFailureMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .default, handler: { [weak self] _ in _ = self?.navigationController?.popViewController(animated: true) })
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    func handleCommonResponses(_ url: URL) -> (failedLogin: Bool, shouldStartLoad: Bool) {
        if url.absoluteString.contains("/oauthFailure") {
            self.presentUnexpectedAuthError()
            return (true, false)
        } else if url.absoluteString.contains("/oauth2/deny") {
            _ = self.navigationController?.popViewController(animated: true)
            return (true, false)
        } else if url.absoluteString.contains("404") {
            backButton.tintColor = UIColor.black
            return (true, true)
        }
        
        return (false, false)
    }
}

class AddStudentViewController: WebLoginViewController {
    
    var completionHandler: ((Result<Bool, NSError>)->Void)?
    let refresher: Refresher

    init(session: Session, domain: URL, authenticationProvider: String?, completionHandler: @escaping (Result<Bool, NSError>)->Void) throws {
        self.refresher = try Student.observedStudentsRefresher(session)
        
        super.init(request: try? AirwolfAPI.addStudentRequest(session, parentID: session.user.id, studentDomain: domain, authenticationProvider: authenticationProvider), loginFailureMessage: NSLocalizedString("Unexpected Authentication Error.  Please try logging in again", comment: "Auth Failed Message"))
        
        webView.delegate = self
        self.completionHandler = completionHandler
    }
    
    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Can't handle storyboards so don't even try."
    }
}

extension AddStudentViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            if url.description == "about.blank" {
                return false
            }

            let commonErrorResults = handleCommonResponses(url)
            if commonErrorResults.failedLogin {
                return commonErrorResults.shouldStartLoad
            }

            // Prevents us from accidentally showing canvas web
            // logged in as the student.
            if url.queryItemForKey("login_success") != nil {
                return false
            }

            if url.absoluteString.contains("/oauthSuccess") {
                // Clear the cookies so you're not automatically logged into a session on the next browser launch
                clearExistingCookies()
                refresher.refreshingCompleted.observeValues { [weak self] _ in
                    self?.completionHandler?(.success(true))
                }
                refresher.refresh(true)
                return false
            }
        }

        return true
    }
}
