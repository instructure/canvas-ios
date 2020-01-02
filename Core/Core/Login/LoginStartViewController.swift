//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class LoginStartViewController: UIViewController {
    @IBOutlet weak var authenticationMethodLabel: UILabel!
    @IBOutlet weak var canvasNetworkButton: UIButton!
    @IBOutlet weak var findSchoolButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var logoYCenter: NSLayoutConstraint!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var previousLoginsBottom: NSLayoutConstraint!
    @IBOutlet weak var previousLoginsLabel: UILabel!
    @IBOutlet weak var previousLoginsTableView: UITableView!
    @IBOutlet weak var previousLoginsView: UIView!
    @IBOutlet weak var whatsNewContainer: UIView!
    @IBOutlet weak var whatsNewLabel: UILabel!
    @IBOutlet weak var whatsNewLink: UIButton!
    @IBOutlet weak var wordmarkLabel: UILabel!

    let env = AppEnvironment.shared
    weak var loginDelegate: LoginDelegate?
    var mdmObservation: NSKeyValueObservation?
    var method = AuthenticationMethod.normalLogin
    var sessions: [LoginSession] = []
    var shouldAnimateFromLaunchScreen = false

    static func create(loginDelegate: LoginDelegate?, fromLaunch: Bool) -> LoginStartViewController {
        let controller = loadFromStoryboard()
        controller.loginDelegate = loginDelegate
        controller.shouldAnimateFromLaunchScreen = fromLaunch
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .named(.backgroundLightest)

        canvasNetworkButton.setTitle(NSLocalizedString("Canvas Network", bundle: .core, comment: ""), for: .normal)
        canvasNetworkButton.isHidden = loginDelegate?.supportsCanvasNetwork == false
        findSchoolButton.setTitle(NSLocalizedString("Find my school", bundle: .core, comment: ""), for: .normal)
        helpButton.accessibilityLabel = NSLocalizedString("Help", bundle: .core, comment: "")
        helpButton.isHidden = !Bundle.main.isParentApp
        authenticationMethodLabel.isHidden = true
        logoView.tintColor = .currentLogoColor()
        previousLoginsView.isHidden = true
        previousLoginsLabel.text = NSLocalizedString("Previous Logins", bundle: .core, comment: "")
        whatsNewLabel.text = NSLocalizedString("We've made a few changes.", bundle: .core, comment: "")
        whatsNewLink.setTitle(NSLocalizedString("See what's new.", bundle: .core, comment: ""), for: .normal)
        whatsNewContainer.isHidden = loginDelegate?.whatsNewURL == nil
        wordmarkLabel.attributedText = NSAttributedString.init(string: (
            Bundle.main.isParentApp ? "PARENT"
            : Bundle.main.isTeacherApp ? "TEACHER"
            : "STUDENT"
        ), attributes: [.kern: 2])
        wordmarkLabel.textColor = .currentLogoColor()

        if MDMManager.shared.host != nil {
            canvasNetworkButton.isHidden = true
            findSchoolButton.setTitle(NSLocalizedString("Log In", bundle: .core, comment: ""), for: .normal)
        }
        mdmObservation = MDMManager.shared.observe(\.loginsRaw, changeHandler: { [weak self] _, _ in
            self?.update()
        })

        update()
        refreshLogins()
    }

    func refreshLogins() {
        for session in LoginSession.sessions {
            URLSessionAPI(session: session).makeRequest(GetUserRequest(userID: session.userID)) { [weak self] (response, _, error) in performUIUpdate {
                guard let response = response, error == nil else { return }
                let entry = LoginSession(
                    accessToken: session.accessToken,
                    baseURL: session.baseURL,
                    expiresAt: session.expiresAt,
                    lastUsedAt: session.lastUsedAt,
                    locale: response.locale ?? response.effective_locale,
                    masquerader: session.masquerader,
                    refreshToken: session.refreshToken,
                    userAvatarURL: response.avatar_url?.rawValue,
                    userID: session.userID,
                    userName: response.short_name,
                    userEmail: response.email,
                    clientID: session.clientID,
                    clientSecret: session.clientSecret
                )
                if LoginSession.sessions.contains(entry) {
                    LoginSession.add(entry)
                }
                if AppEnvironment.shared.currentSession == entry {
                    AppEnvironment.shared.currentSession = entry
                }
                self?.update()
            } }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        guard shouldAnimateFromLaunchScreen else { return }

        for view in view.subviews {
            view.alpha = 0
        }
        logoView.alpha = 1
        logoYCenter.constant = 0
        previousLoginsBottom.constant = -previousLoginsView.frame.height
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard shouldAnimateFromLaunchScreen else { return }
        shouldAnimateFromLaunchScreen = false
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.75, delay: 0.25, animations: {
            self.logoYCenter.constant = -170
            self.view.layoutIfNeeded()
        }, completion: fadeIn)
    }

    func fadeIn(_ completed: Bool) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            for view in self.view.subviews {
                view.alpha = 1
            }
            self.view.layoutIfNeeded()
        }, completion: springPreviousLogins)
    }

    func springPreviousLogins(_ completed: Bool) {
        guard previousLoginsView?.isHidden == false else { return }
        view.layoutIfNeeded()
        UIView.animate(
            withDuration: 0.5,
            delay: 0.5,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 2,
            options: .curveEaseOut,
            animations: {
                self.previousLoginsBottom.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    func update() {
        sessions = LoginSession.sessions.sorted { a, b in a.lastUsedAt > b.lastUsedAt }
        previousLoginsView.isHidden = sessions.isEmpty && MDMManager.shared.logins.isEmpty
        previousLoginsTableView.reloadData()
    }

    @IBAction func canvasNetworkTapped(_ sender: UIButton) {
        let controller = LoginWebViewController.create(host: "learn.canvas.net", loginDelegate: loginDelegate, method: method)
        env.router.show(controller, from: self)
    }

    @IBAction func findTapped(_ sender: UIButton) {
        var controller: UIViewController = LoginFindSchoolViewController.create(loginDelegate: loginDelegate, method: method)
        if let host = MDMManager.shared.host {
            let provider = MDMManager.shared.authenticationProvider
            if method == .manualOAuthLogin {
                controller = LoginManualOAuthViewController.create(
                    authenticationProvider: provider,
                    host: host,
                    loginDelegate: loginDelegate
                )
            } else {
                controller = LoginWebViewController.create(
                    authenticationProvider: provider,
                    host: host,
                    loginDelegate: loginDelegate,
                    method: method
                )
            }
        }
        env.router.show(controller, from: self)
    }

    @IBAction func helpTapped(_ sender: UIButton) {
        loginDelegate?.openSupportTicket()
    }

    @IBAction func whatsNewTapped(_ sender: UIButton) {
        guard let url = loginDelegate?.whatsNewURL else { return }
        loginDelegate?.openExternalURL(url)
    }

    @IBAction func authMethodTapped(_ sender: UIView) {
        switch method {
        case .normalLogin:
            method = .canvasLogin
            authenticationMethodLabel.text = NSLocalizedString("Canvas Login", bundle: .core, comment: "")
        case .canvasLogin:
            method = .siteAdminLogin
            authenticationMethodLabel.text = NSLocalizedString("Site Admin Login", bundle: .core, comment: "")
        case .siteAdminLogin:
            method = .manualOAuthLogin
            authenticationMethodLabel.text = NSLocalizedString("Manual OAuth Login", bundle: .core, comment: "")
        case .manualOAuthLogin:
            method = .normalLogin
            authenticationMethodLabel.text = nil
        }
        authenticationMethodLabel.isHidden = authenticationMethodLabel.text == nil
    }
}

extension LoginStartViewController: UITableViewDataSource, UITableViewDelegate, LoginStartSessionDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count + MDMManager.shared.logins.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < sessions.count {
            let cell: LoginStartSessionCell = tableView.dequeue(for: indexPath)
            cell.update(entry: sessions[indexPath.row], delegate: self)
            return cell
        }

        let cell: LoginStartMDMLoginCell = tableView.dequeue(for: indexPath)
        cell.update(login: MDMManager.shared.logins[indexPath.row - sessions.count])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < sessions.count {
            env.router.show(LoadingViewController.create(), from: self)
            loginDelegate?.userDidLogin(session: sessions[indexPath.row].bumpLastUsedAt())
            return
        }

        let login = MDMManager.shared.logins[indexPath.row - sessions.count]
        let controller = LoginWebViewController.create(
            authenticationProvider: nil,
            host: login.host,
            mdmLogin: login,
            loginDelegate: loginDelegate,
            method: .canvasLogin
        )
        env.router.show(controller, from: self)
    }

    func removeSession(_ session: LoginSession) {
        guard let row = sessions.firstIndex(of: session) else { return }
        sessions.remove(at: row)
        previousLoginsTableView?.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        loginDelegate?.userDidLogout(session: session)
        if sessions.isEmpty && MDMManager.shared.logins.isEmpty {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5) {
                self.previousLoginsBottom?.constant = -self.previousLoginsView.frame.height
                self.view.layoutIfNeeded()
            }
        }
    }
}
