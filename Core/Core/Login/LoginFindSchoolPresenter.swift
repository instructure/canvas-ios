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

import UIKit

protocol LoginFindSchoolViewProtocol: class {
    func show(_ vc: UIViewController, sender: Any?)
    func update(results: [(domain: String, name: String)])
}

class LoginFindSchoolPresenter {
    var accounts = [APIAccountResults]()
    var api: API = URLSessionAPI(urlSession: URLSession.shared)
    let method: AuthenticationMethod
    weak var loginDelegate: LoginDelegate?
    var queue = OperationQueue()
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

        let useCase = GetAccounts(api: api, searchTerm: query)
        useCase.completionBlock = { [weak self] in DispatchQueue.main.async {
            guard let self = self, !useCase.isCancelled else { return }
            self.accounts = useCase.response ?? []
            self.view?.update(results: self.accounts.map { (account) -> (domain: String, name: String) in
                return (domain: account.domain, name: account.name.trimmingCharacters(in: .whitespacesAndNewlines))
            })
        } }
        queue.cancelAllOperations()
        queue.addOperation(useCase)
    }

    func showHelp() {
        guard let url = loginDelegate?.helpURL else { return }
        loginDelegate?.openExternalURL(url)
    }

    func showLoginForHost(_ host: String) {
        let authenticationProvider = accounts.first(where: { $0.domain == host })?.authentication_provider
        let controller: UIViewController
        if method == .manualOAuthLogin {
            controller = LoginManualOAuthViewController.create(
                authenticationProvider: authenticationProvider,
                host: host,
                loginDelegate: loginDelegate
            )
        } else {
            controller = LoginWebViewController.create(
                authenticationProvider: authenticationProvider,
                host: host,
                loginDelegate: loginDelegate,
                method: method
            )
        }
        view?.show(controller, sender: nil)
    }
}
