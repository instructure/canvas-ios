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

import Combine
import CombineExt
import WebKit

public enum StudioAPIAuthError: String, Error, DebugDescriptionProvider {
    case failedToGetLTIs
    case failedToGetTokenFromWebView
    case failedToGetAPIBaseURL
    case studioLTINotFound
    case failedToGetLaunchURL

    public var debugDescription: String {
        "\(Self.self).\(self)"
    }
}

public protocol StudioAPIAuthInteractor {
    func makeStudioAPI(env: AppEnvironment) -> AnyPublisher<API, StudioAPIAuthError>
}

public class StudioAPIAuthInteractorLive: StudioAPIAuthInteractor {
    private let webViewFactory: () -> WKWebView

    /// - parameters:
    ///   - webViewFactory: Injection point for a WKWebView for testing purposes.
    public init(
        webViewFactory: @escaping () -> WKWebView = { WKWebView(frame: .zero) }
    ) {
        self.webViewFactory = webViewFactory
    }

    public func makeStudioAPI(env: AppEnvironment) -> AnyPublisher<API, StudioAPIAuthError> {
        Self.getStudioLaunchURL(env: env)
            .flatMap { [self] (webLaunchURL, apiBaseURL) in
                launchStudioInHeadlessWebView(webLaunchURL: webLaunchURL)
                    .map { webView in
                        (webView, apiBaseURL)
                    }
            }
            .flatMap { (webView, apiBaseURL) in
                Self.getSessionToken(studioWebView: webView)
                    .map { (userId, token) in
                        (userId, token, apiBaseURL)
                    }
            }
            .map { userId, token, apiBaseURL in
                LoginSession(
                    accessToken: "user_id=\"\(userId)\", token=\"\(token)\"",
                    baseURL: apiBaseURL,
                    userID: "",
                    userName: ""
                )
            }
            .map { API($0) }
            .eraseToAnyPublisher()
    }

    /// Launching studio in the background for two reasons:
    /// - To get the access token to the API
    /// - To trigger a permission sync between canvas courses and Studio
    private func launchStudioInHeadlessWebView(webLaunchURL: URL) -> AnyPublisher<WKWebView, Never> {
        let webView = webViewFactory()
        webView.load(URLRequest(url: webLaunchURL))
        return webView
            .waitUntilLoadFinishes(checkInterval: 5)
            .map { webView }
            .eraseToAnyPublisher()
    }

    private static func getSessionToken(studioWebView: WKWebView) -> AnyPublisher<(userId: String, token: String), StudioAPIAuthError> {
        studioWebView
            .evaluateJavaScript(js: "sessionStorage.getItem('token')")
            .flatMap { token in
                studioWebView
                    .evaluateJavaScript(js: "sessionStorage.getItem('userId')")
                    .map { userId in (userId, token) }
            }
            .tryMap { (userId, token) in
                guard let token = token as? String,
                      let userId = userId as? String
                else {
                    throw StudioAPIAuthError.failedToGetTokenFromWebView
                }
                return (userId: userId, token: token)
            }
            .mapUnknownErrors(to: .failedToGetTokenFromWebView)
            .eraseToAnyPublisher()
    }

    private static func getStudioLaunchURL(env: AppEnvironment) -> AnyPublisher<(webLaunchURL: URL, apiBaseURL: URL), StudioAPIAuthError> {
        let useCase = GetGlobalNavExternalToolsPlacements(enrollment: .student)
        return ReactiveStore(useCase: useCase, environment: env)
            .getEntities()
            .tryMap { ltiTools -> (URL, URL) in
                guard let webURL = ltiTools.studioLTITool?.url else {
                    throw StudioAPIAuthError.studioLTINotFound
                }
                guard let baseURL = webURL.apiBaseURL else {
                    throw StudioAPIAuthError.failedToGetAPIBaseURL
                }
                return (webURL, baseURL)
            }
            .mapUnknownErrors(to: .failedToGetLTIs)
            .flatMap { (webURL, baseURL) in
                LTITools(url: webURL, isQuizLTI: false, env: env)
                    .getSessionlessLaunchURL()
                    .mapError { _ in StudioAPIAuthError.failedToGetLaunchURL }
                    .map { (webLaunchURL: $0, apiBaseURL: baseURL) }
            }
            .eraseToAnyPublisher()
    }
}

private extension Publisher {

    func mapUnknownErrors(to newError: StudioAPIAuthError) -> Publishers.MapError<Self, StudioAPIAuthError> {
        mapError { error in
            guard let studioError = error as? StudioAPIAuthError else {
                return newError
            }
            return studioError
        }
    }
}

private extension Array where Element == ExternalToolLaunchPlacement {

    var studioLTITool: ExternalToolLaunchPlacement? {
        first { ltiTool in
            guard let url = ltiTool.url else {
                return false
            }
            return url.absoluteString.contains(".instructuremedia.com") && !url.absoluteString.contains("staging")
        }
    }
}
