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

protocol LoginFindSchoolViewProtocol: class {
    func show(_ vc: UIViewController, sender: Any?)
    func update(results: [APIAccountResult])
}

class LoginFindSchoolPresenter {
    var accounts = [APIAccountResult]()
    var api: API = URLSessionAPI()
    let method: AuthenticationMethod
    weak var loginDelegate: LoginDelegate?
    var searchTask: URLSessionTask?
    weak var view: LoginFindSchoolViewProtocol?

    init(loginDelegate: LoginDelegate?, method: AuthenticationMethod, view: LoginFindSchoolViewProtocol) {
        self.loginDelegate = loginDelegate
        self.method = method
        self.view = view
    }

    func viewIsReady() {
    }

    func search(query: String) {
        guard !query.isEmpty else {
            view?.update(results: [])
            return
        }

        searchTask?.cancel()
        searchTask = api.makeRequest(GetAccountsSearchRequest(searchTerm: query)) { [weak self] (results, _, error) in DispatchQueue.main.async {
            guard let self = self, error == nil else { return }
            self.accounts = results ?? []
            self.view?.update(results: self.accounts.map { (account) -> APIAccountResult in
                return APIAccountResult(
                    name: account.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    domain: account.domain,
                    authentication_provider: account.authentication_provider
                )
            })
            self.searchTask = nil
        } }
    }

    func showHelp() {
        guard let url = loginDelegate?.helpURL else { return }
        loginDelegate?.openExternalURL(url)
    }

    func showLoginForHost(_ host: String, authenticationProvider: String? = nil) {
        let provider = authenticationProvider ?? accounts.first(where: { $0.domain == host })?.authentication_provider
        let controller: UIViewController
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
        view?.show(controller, sender: nil)
    }
}
