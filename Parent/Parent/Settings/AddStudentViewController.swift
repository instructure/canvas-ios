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
import SoLazy
import TooLegit
import Airwolf
import SoPersistent
import Armchair
import SoPretty

class WebLoginViewController: UIViewController {
    
    let request: URLRequest?
    let useBackButton: Bool
    let loginFailureMessage: String
    var prompt: String? = nil
    
    let webView = UIWebView()
    fileprivate let backButton = UIButton(type: .custom)
    fileprivate let statusBarNotification = ToastManager()
    
    init(request: URLRequest?, useBackButton: Bool, loginFailureMessage: String) {
        self.request = request
        self.useBackButton = useBackButton
        self.loginFailureMessage = loginFailureMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearExistingCookies()
        
        setupWebView()
        setupBackButton()
        
        startLoginRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let prompt = prompt {
            statusBarNotification.statusBarToastInfo(prompt)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        statusBarNotification.dismissNotification()
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
    
    func setupBackButton() {
        if let navController = self.navigationController, !navController.isNavigationBarHidden {
            return
        }
        let backImage = UIImage.RTLImage("icon_back", renderingMode: .alwaysTemplate)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setBackgroundImage(backImage, for: .normal)
        backButton.setBackgroundImage(backImage, for: .selected)
        backButton.tintColor = UIColor.white
        
        self.view.addSubview(backButton)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[subview]", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": backButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[subview]", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": backButton]))
        
        backButton.addConstraint(NSLayoutConstraint(item: backButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
        backButton.addConstraint(NSLayoutConstraint(item: backButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
        
        backButton.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        backButton.isHidden = !useBackButton
    }
    
    func setupWebView() {
        self.automaticallyAdjustsScrollViewInsets = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = UIColor.black
        self.view.addSubview(webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webview]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webview": webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webview]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webview": webView]))
    }
    
    func backButtonPressed(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
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

    init(session: Session, domain: URL, useBackButton: Bool = false, completionHandler: @escaping (Result<Bool, NSError>)->Void) throws {
        self.refresher = try Student.observedStudentsRefresher(session)
        
        super.init(request: try? AirwolfAPI.addStudentRequest(session, parentID: session.user.id, studentDomain: domain), useBackButton: useBackButton, loginFailureMessage: NSLocalizedString("Unexpected Authentication Error.  Please try logging in again", comment: "Auth Failed Message"))
        
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
            
            if url.absoluteString.contains("/oauthSuccess") {
                // Clear the cookies so you're not automatically logged into a session on the next browser launch
                Armchair.userDidSignificantEvent(true)
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
