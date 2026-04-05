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

import Combine
import UIKit

final class LoginFindSchoolViewModel {

    enum State { case idle, searching, loaded, loadingNextPage, nextPageFailed }

    private(set) var accounts: [APIAccountResult] = []
    var hasNextPage: Bool { nextPageRequest != nil }

    let state = CurrentValueSubject<State, Never>(.idle)
    let env: AppEnvironment = .shared

    var method = AuthenticationMethod.normalLogin
    weak var loginDelegate: LoginDelegate?

    private var searchTask: APITask?
    private var pageTask: APITask?
    private var nextPageRequest: GetNextRequest<[APIAccountResult]>?

    func search(query: String) {
        guard !query.isEmpty else {
            accounts = []
            nextPageRequest = nil
            pageTask?.cancel()
            pageTask = nil
            state.send(.idle)
            return
        }

        searchTask?.cancel()
        pageTask?.cancel()
        pageTask = nil
        nextPageRequest = nil
        state.send(.searching)

        let request = GetAccountsSearchRequest(searchTerm: query)
        searchTask = env.api.makeRequest(request) { [weak self] (results, urlResponse, error) in
            performUIUpdate {
                guard let self, error == nil else { return }
                self.accounts = results?.sortedPromotingQueryPrefixed(query) ?? []
                self.nextPageRequest = urlResponse.flatMap { request.getNext(from: $0) }
                self.searchTask = nil
                self.state.send(.loaded)
            }
        }
    }

    func loadNextPage() {
        guard let nextReq = nextPageRequest,
              state.value == .loaded || state.value == .nextPageFailed else { return }
        state.send(.loadingNextPage)
        pageTask = env.api.makeRequest(nextReq) { [weak self] (results, urlResponse, error) in
            performUIUpdate {
                guard let self else { return }
                guard error == nil else {
                    self.pageTask = nil
                    self.state.send(.nextPageFailed)
                    return
                }
                self.accounts.append(contentsOf: results ?? [])
                self.nextPageRequest = urlResponse.flatMap { nextReq.getNext(from: $0) }
                self.pageTask = nil
                self.state.send(.loaded)
            }
        }
    }

    func accountDomain(from textInput: String?) -> String? {
        guard var host = textInput, !host.isEmpty else { return nil }

        host = host.lowercased()

        // For manual oauth logins we trust the developer and don't modify the host.
        if method != .manualOAuthLogin, !host.contains(".") {
            return "\(host).instructure.com"
        }

        return host
    }

    var rowsCount: Int {
        if accounts.isEmpty {
            return 1
        }
        switch state.value {
        case .loadingNextPage, .nextPageFailed:
            return accounts.count + 1
        default:
            return accounts.count
        }
    }

    func rowWillDisplay(at indexPath: IndexPath) {
        guard !accounts.isEmpty,
              state.value == .loaded,
              hasNextPage,
              indexPath.row == accounts.count - 1 else { return }

        loadNextPage()
    }

    func rowSelected(at indexPath: IndexPath, in viewController: UIViewController) {
        if accounts.isEmpty {
            openHelpPage()
        } else if indexPath.row == accounts.count && state.value == .nextPageFailed {
            loadNextPage()
        } else {
            guard indexPath.row < accounts.count else { return }
            showLoginForAccount(accounts[indexPath.row], from: viewController)
        }
    }

    func showLoginForAccount(_ account: APIAccountResult, from viewController: UIViewController) {
        env.lastLoginAccount = account
        showLoginForHost(account.domain, authenticationProvider: account.authentication_provider, from: viewController)
    }

    private func showLoginForHost(_ host: String, authenticationProvider: String? = nil, from viewController: UIViewController) {

        let controller: UIViewController
        var analyticsRoute = "/login/find"

        if method == .manualOAuthLogin {
            controller = LoginManualOAuthViewController.create(
                authenticationProvider: authenticationProvider,
                host: host,
                loginDelegate: loginDelegate
            )
            analyticsRoute = "/login/manualoauth"
        } else {
            controller = LoginWebViewController.create(
                authenticationProvider: authenticationProvider,
                host: host,
                loginDelegate: loginDelegate,
                method: method
            )
            analyticsRoute = "/login/weblogin"
        }

        env.router.show(controller, from: viewController, analyticsRoute: analyticsRoute)
    }

    private func openHelpPage() {
        guard
            let loginDelegate,
            let url = loginDelegate.helpURL
        else { return }

        loginDelegate.openExternalURL(url)
    }
}
