//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import Combine
import WebKit

protocol ParentSubmissionInteractor {

    init(
        assignmentHtmlURL: URL,
        observedUserID: String,
        loginSession: LoginSession?,
        api: API
    )

    func loadParentFeedbackView(
        webView: WKWebView
    ) -> AnyPublisher<Void, Error>
}

struct ParentSubmissionInteractorLive: ParentSubmissionInteractor {
    private let assignmentHtmlURL: URL
    private let observedUserID: String
    private let loginSession: LoginSession?
    private let api: API

    init(
        assignmentHtmlURL: URL,
        observedUserID: String,
        loginSession: LoginSession? = AppEnvironment.shared.currentSession,
        api: API = AppEnvironment.shared.api
    ) {
        self.assignmentHtmlURL = assignmentHtmlURL
        self.observedUserID = observedUserID
        self.loginSession = loginSession
        self.api = api
    }

    func loadParentFeedbackView(
        webView: WKWebView
    ) -> AnyPublisher<Void, Error> {
        api.makeRequest(GetWebSessionRequest(to: assignmentHtmlURL))
            .tryMap { (body, _) in
                guard let loginSession,
                      let domain = loginSession.baseURL.host()
                else {
                    throw NSError.internalError()
                }
                let parentUserID = loginSession.userID

                let cookie = HTTPCookie(properties: [
                    .name: "k5_observed_user_for_\(parentUserID)",
                    .value: observedUserID,
                    .domain: domain,
                    .path: "/"
                ])

                guard let cookie else {
                    throw NSError.internalError()
                }

                return (request: URLRequest(url: body.session_url), cookie: cookie)
            }
            .receive(on: RunLoop.main)
            .flatMap { (request: URLRequest, cookie: HTTPCookie) in
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
                    .map { request }
            }
            .flatMap { request in
                webView.load(request)
                return webView.waitUntilLoadFinishes(checkInterval: 2)
            }
            .eraseToAnyPublisher()
    }
}
