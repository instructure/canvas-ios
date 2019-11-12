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

import Foundation
import UIKit

enum Login: Equatable {
    case session(LoginSession)
    case mdm(MDMLogin)
}

protocol LoginStartViewProtocol: class {
    func update(method: String?)
    func update(logins: [Login])
    func show(_ vc: UIViewController, sender: Any?)
}

class LoginStartPresenter {
    var method = AuthenticationMethod.normalLogin
    weak var loginDelegate: LoginDelegate?
    weak var view: LoginStartViewProtocol?
    var urlSession = URLSessionAPI.defaultURLSession
    var mdmObservation: NSKeyValueObservation?

    init(loginDelegate: LoginDelegate?, view: LoginStartViewProtocol) {
        self.loginDelegate = loginDelegate
        self.view = view
    }

    func viewIsReady() {
        loadEntries()
        let group = DispatchGroup()
        var refreshed = Set<LoginSession>()
        for session in LoginSession.sessions {
            let api = URLSessionAPI(session: session, urlSession: urlSession)
            group.enter()
            api.makeRequest(GetUserRequest(userID: session.userID)) { (response, _, error) in
                if let response = response, error == nil {
                    refreshed.insert(LoginSession(
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
                    ))
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            for entry in refreshed {
                if LoginSession.sessions.contains(entry) {
                    LoginSession.add(entry)
                }
                if AppEnvironment.shared.currentSession == entry {
                    AppEnvironment.shared.currentSession = entry
                }
            }
            self?.loadEntries()
        }

        mdmObservation = MDMManager.shared.observe(\.loginsRaw, changeHandler: { [weak self] _, _ in
            self?.loadEntries()
        })
    }

    func loadEntries() {
        var logins = LoginSession.sessions
            .sorted { a, b in a.lastUsedAt > b.lastUsedAt }
            .map { Login.session($0) }
        logins.append(contentsOf: MDMManager.shared.logins.map { Login.mdm($0) })
        view?.update(logins: logins)
    }

    func cycleAuthMethod() {
        switch method {
        case .normalLogin:
            method = .canvasLogin
            view?.update(method: NSLocalizedString("Canvas Login", bundle: .core, comment: ""))
        case .canvasLogin:
            method = .siteAdminLogin
            view?.update(method: NSLocalizedString("Site Admin Login", bundle: .core, comment: ""))
        case .siteAdminLogin:
            method = .manualOAuthLogin
            view?.update(method: NSLocalizedString("Manual OAuth Login", bundle: .core, comment: ""))
        case .manualOAuthLogin:
            method = .normalLogin
            view?.update(method: nil)
        }
    }

    func openCanvasNetwork() {
        let controller = LoginWebViewController.create(host: "learn.canvas.net", loginDelegate: loginDelegate, method: method)
        view?.show(controller, sender: nil)
    }

    func openFindSchool() {
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
        view?.show(controller, sender: nil)
    }

    func openHelp() {
        loginDelegate?.openSupportTicket()
    }

    func openWhatsNew() {
        guard let url = loginDelegate?.whatsNewURL else { return }
        loginDelegate?.openExternalURL(url)
    }

    func selectSession(_ session: LoginSession) {
        let controller = LoadingViewController.create()
        view?.show(controller, sender: nil)
        loginDelegate?.userDidLogin(session: session.bumpLastUsedAt())
    }

    func removeSession(_ session: LoginSession) {
        // View has already updated itself.
        loginDelegate?.userDidLogout(session: session)
    }

    func selectMDMLogin(_ login: MDMLogin) {
        let controller = LoginWebViewController.create(
            authenticationProvider: nil,
            host: login.host,
            mdmLogin: login,
            loginDelegate: loginDelegate,
            method: .canvasLogin
        )
        view?.show(controller, sender: nil)
    }
}
