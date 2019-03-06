//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation

protocol LoginStartViewProtocol: class {
    func update(method: String?)
    func update(logins: [KeychainEntry])
    func show(_ vc: UIViewController, sender: Any?)
}

class LoginStartPresenter {
    var method = AuthenticationMethod.normalLogin
    weak var loginDelegate: LoginDelegate?
    weak var view: LoginStartViewProtocol?
    var session = URLSession.shared

    init(loginDelegate: LoginDelegate?, view: LoginStartViewProtocol) {
        self.loginDelegate = loginDelegate
        self.view = view
    }

    func viewIsReady() {
        loadEntries()
        let group = DispatchGroup()
        var refreshed = Set<KeychainEntry>()
        for entry in Keychain.entries {
            let api = URLSessionAPI(accessToken: entry.accessToken, baseURL: entry.baseURL, urlSession: session)
            group.enter()
            api.makeRequest(GetUserRequest(userID: entry.userID)) { (response, _, error) in
                if let response = response, error == nil {
                    refreshed.insert(KeychainEntry(
                        accessToken: entry.accessToken,
                        baseURL: entry.baseURL,
                        expiresAt: entry.expiresAt,
                        lastUsedAt: entry.lastUsedAt,
                        locale: response.locale ?? response.effective_locale,
                        masquerader: entry.masquerader,
                        refreshToken: entry.refreshToken,
                        userAvatarURL: response.avatar_url,
                        userID: entry.userID,
                        userName: response.name,
                        userEmail: response.email
                    ))
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            for entry in refreshed {
                if Keychain.entries.contains(entry) {
                    Keychain.addEntry(entry)
                }
                if Keychain.currentSession == entry {
                    Keychain.currentSession = entry
                }
            }
            self?.loadEntries()
        }
    }

    func loadEntries() {
        view?.update(logins: Keychain.entries.sorted(by: { a, b in a.lastUsedAt > b.lastUsedAt }))
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
        let controller = LoginFindSchoolViewController.create(loginDelegate: loginDelegate, method: method)
        view?.show(controller, sender: nil)
    }

    func openHelp() {
        loginDelegate?.openSupportTicket()
    }

    func openWhatsNew() {
        guard let url = loginDelegate?.whatsNewURL else { return }
        loginDelegate?.openExternalURL(url)
    }

    func selectPreviousLogin(_ entry: KeychainEntry) {
        let controller = LoadingViewController.create()
        view?.show(controller, sender: nil)
        loginDelegate?.userDidLogin(keychainEntry: entry.bumpLastUsedAt())
    }

    func removePreviousLogin(_ entry: KeychainEntry) {
        // View has already updated itself.
        loginDelegate?.userDidLogout(keychainEntry: entry)
    }
}
