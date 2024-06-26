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

public struct GetStudioCourseMedia: APIRequestable {
    public typealias Response = APINoContent

    public var path: String { "/api/public/v1/courses/\(courseId)/media" }

    private var courseId: String

    public init(courseId: String) {
        self.courseId = courseId
    }
}

class StudioMediaInteractor {

    enum StudioError: Error {
        case failedToGetLTIs
        case failedToGetTokenFromWebView
        case studioLTINotFound
        case failedToGetLaunchURL
        case tokenNotFound
        case unknown
    }

//    static func getStudioToken() -> AnyPublisher<String, StudioError> {
//        WKWebViewConfiguration
//            .defaultConfiguration
//            .websiteDataStore
//            .httpCookieStore
//            .getAllCookies()
//            .tryMap { cookies in
//                guard let token = cookies.studioToken else {
//                    throw StudioError.tokenNotFound
//                }
//                return token
//            }
//            .mapErrorToStudioError()
//            .eraseToAnyPublisher()
//    }

    static func makeStudioAPI() -> AnyPublisher<API, StudioError> {
        getStudioSession()
            .map { userId, token in
                LoginSession.makeStudioSession(token: "user_id=\"\(userId)\", token=\"\(token)\"")
            }
            .map { API($0) }
            .eraseToAnyPublisher()
    }

    static func getStudioSession() -> AnyPublisher<(userId: String, token: String), StudioError> {
        getStudioLaunchURL()
            .map { launchURL -> CoreWebView in
                let webView = CoreWebView(features: [])
                webView.load(URLRequest(url: launchURL))
                return webView
            }
            .delay(for: 10, scheduler: RunLoop.main)
            .flatMap { webView in
                Publishers.CombineLatest(
                    webView.evaluateJavaScript(js: "sessionStorage.getItem('userId')"),
                    webView.evaluateJavaScript(js: "sessionStorage.getItem('token')")
                )
                .mapError { _ in StudioError.failedToGetTokenFromWebView }
            }
            .retry(100)
            .tryMap { (userId, token) in
                guard let token = token as? String, let userId = userId as? String else {
                    throw StudioError.failedToGetTokenFromWebView
                }
                return (userId: userId, token: token)
            }
            .mapErrorToStudioError()
            .eraseToAnyPublisher()
    }

    static func getStudioLaunchURL() -> AnyPublisher<URL, StudioError> {
        let useCase = GetGlobalNavExternalToolsPlacements(enrollment: .student)
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .tryMap { ltiTools -> URL in
                guard let studioURL = ltiTools.studioLTITool?.url else {
                    throw StudioError.studioLTINotFound
                }
                return studioURL
            }
            .mapErrorToStudioError()
            .flatMap { studioURL in
                LTITools(url: studioURL)
                    .getSessionlessLaunchURL()
                    .mapError { _ in StudioError.failedToGetLaunchURL }
            }
            .eraseToAnyPublisher()
    }
}

public extension WKWebView {

    func evaluateJavaScript(js: String) -> AnyPublisher<Any, Error> {
        Future { promise in
            self.evaluateJavaScript(js) { result, error in
                if let result {
                    promise(.success(result))
                } else {
                    promise(.failure(error ?? NSError.internalError()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

private extension Publisher {

    func mapErrorToStudioError(
    ) -> Publishers.MapError<Self, StudioMediaInteractor.StudioError> {
        self.mapError { error in
            guard let studioError = error as? StudioMediaInteractor.StudioError else {
                return .unknown
            }
            return studioError
        }
    }
}

public extension LoginSession {

    static func makeStudioSession(token: String) -> LoginSession {
        .init(
            accessToken: token,
            baseURL: URL(string: "https://attilavarga.staging.instructuremedia.com")!,
            userID: "",
            userName: ""
        )
    }
}

public extension WKHTTPCookieStore {

    func getAllCookies() -> AnyPublisher<[HTTPCookie], Never> {
        Future { promise in
            self.getAllCookies { cookies in
                promise(.success(cookies))
            }
        }.eraseToAnyPublisher()
    }
}

public extension Array where Element == HTTPCookie {

    var studioToken: String? {
        first { cookie in
            if cookie.name.contains("arc"), cookie.name.contains("session") {
                return true
            }
            return false
        }
        .map(\.value)
    }
}

public extension Array where Element == ExternalToolLaunchPlacement {

    var studioLTITool: ExternalToolLaunchPlacement? {
        first { ltiTool in
            guard let url = ltiTool.url else {
                return false
            }
            return url.absoluteString.contains("staging.instructuremedia.com")
        }
    }
}
