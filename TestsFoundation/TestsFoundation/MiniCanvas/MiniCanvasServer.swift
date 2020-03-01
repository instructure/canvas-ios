//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Swifter
@testable import Core

extension HttpResponse {
    static func json<E: Encodable>(_ encodable: E?) -> HttpResponse {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(encodable) else { return .internalServerError }
        return .raw(200, "OK", [HttpHeader.contentType: "application/json"]) { writer in
            try writer.write(data)
        }
    }
}

public class LoggingHttpServer: HttpServer {
    public override func dispatch(_ request: HttpRequest) -> ([String: String], (HttpRequest) -> HttpResponse) {
        let (params, handler) = super.dispatch(request)
        return (params, { request in
            let response = handler(request)
            var queryString = ""
            if !request.queryParams.isEmpty {
                queryString = " \(request.queryParams)"
            }
            let alert = response.statusCode >= 400 ? "" : " ❌"
            print("\(request.method) \(request.path)\(queryString) \(response.statusCode)\(alert)")
            return response
        })
    }
}

extension HttpRequest {
    func firstQueryParam(named name: String) -> String? {
        queryParams.first(where: { $0.0 == name })?.1
    }

    func allQueryParams(named name: String) -> [String] {
        queryParams.compactMap { (paramName, value) in paramName == name ? value : nil }
    }
}

public class MiniCanvasServer {
    public static let shared = MiniCanvasServer.createServer()
    public let server: LoggingHttpServer

    public let port: UInt16
    public let address = "localhost"
    public var host: String { "\(address):\(port)" }
    public var baseUrl: URL { URL(string: "http://\(host)/")! }

    public class State {
        public var courses: [APICourse]
        public func course(byId id: String) -> APICourse? {
            courses.first { $0.id == id }
        }

//        public var enrollments: [APIEnrollment] = []
//        public func enroll(user: .....)

        public var students: [APIUser]
        public var teachers: [APIUser]
        public var observers: [APIUser]
        public var loggedInUserId: String
        public func user(byId id: String) -> APIUser? {
            (students + teachers + observers) .first { $0.id == id }
        }

        public var brandVariables = APIBrandVariables.make()
        public var unreadCount: UInt = 3
        public var accountNotifications: [APIAccountNotification]
        public var customColors: [String: String] = [:]

        class IDGenerator {
            private var nextID: Int = 10
            public func next<I: ExpressibleByIntegerLiteral>() -> I where I.IntegerLiteralType == Int {
                defer { nextID += 1 }
                return I.init(integerLiteral: nextID)
            }
        }
        let idGenerator = IDGenerator()

        init() {
            courses = [
                APICourse.make(id: idGenerator.next(), name: "Course One", course_code: "C1", workflow_state: .available, enrollments: []),
                APICourse.make(id: idGenerator.next(), name: "Course Two (unpublished)", course_code: "C2", workflow_state: .unpublished, enrollments: []),
                APICourse.make(id: idGenerator.next(), name: "Course Three (completed)", course_code: "C3", workflow_state: .completed, enrollments: []),
            ]

            students = [
                APIUser.makeUser(role: "Student", id: idGenerator.next()),
                APIUser.makeUser(role: "Student", id: idGenerator.next()),
            ]
            teachers = [ APIUser.makeUser(role: "Teacher", id: idGenerator.next()) ]
            observers = [ APIUser.makeUser(role: "Parent", id: idGenerator.next()) ]
            loggedInUserId = students[0].id
            accountNotifications = [ .make(id: idGenerator.next()) ]
        }
    }
    public var state = State()
    public func reset() {
        state = State()
    }

    enum APIError: Error {
        case responseError(HttpResponse)

        public static var internalServerError: APIError { .responseError(.internalServerError) }
        public static var notFound: APIError { .responseError(.notFound) }
        public static var unauthorized: APIError { .responseError(.unauthorized) }
    }

    func addRoute(
        _ route: String,
        method: APIMethod = .get,
        handler: @escaping (State, HttpRequest) throws -> HttpResponse
    ) {
        var methodRoute: HttpServer.MethodRoute
        switch method {
        case .delete: methodRoute = server.DELETE
        case .get: methodRoute = server.GET
        case .post: methodRoute = server.POST
        case .put: methodRoute = server.PUT
        }
        // capture state instead of self to avoid retain cycles
        methodRoute[route] = { [state] request in
            do {
                return try handler(state, request)
            } catch APIError.responseError(let response) {
                return response
            } catch {
                return HttpResponse.internalServerError
            }
        }
    }

    // expects a requestable with a path including path parameters like "courses/:courseID"
    func addApiRoute<R: APIRequestable>(
        _ routeRequest: R,
        handler: @escaping (State, HttpRequest) throws -> R.Response?
    ) {
        let urlRequest = try! routeRequest.urlRequest(relativeTo: baseUrl, accessToken: "", actAsUserID: "")
        addRoute(urlRequest.url!.path, method: routeRequest.method) { state, request in
            guard let response = try handler(state, request) else {
                return .notFound
            }
            return .json(response)
        }
    }

    // private because it has leaky reference cycles, so best to just have 1
    private init(port: UInt16) throws {
        server = LoggingHttpServer()
        server.listenAddressIPv6 = "::1"
        try server.start(port)
        self.port = port
        installRoutes()
        NotificationCenter.default.post(name: .init("miniCanvasServerStart"), object: baseUrl)
    }

    private func installRoutes() {
        let verifyClient = APIVerifyClient(authorized: true, base_url: baseUrl, client_id: "i dunno", client_secret: "lol")
        addApiRoute(GetMobileVerifyRequest(domain: "")) { _, _ in verifyClient }

        // https://canvas.instructure.com/doc/api/file.oauth_endpoints.html
        addRoute("/login/oauth2/auth") { _, request in
            guard let redirectUri = request.firstQueryParam(named: "redirect_uri" ) else {
                return .badRequest(nil)
            }
            // login always works
            return .movedTemporarily("\(redirectUri)?code=t")
        }
        addApiRoute(PostLoginOAuthRequest(client: verifyClient, code: "")) { _, _ in APIOAuthToken.make() }
        addApiRoute(GetUserProfileRequest(userID: ":userID")) { state, request in
            var userID = request.params[":userID"]!
            if userID == "self" {
                userID = state.loggedInUserId
            }
            guard let user = state.user(byId: userID) else { return nil }
            return APIProfile.make(
                id: user.id,
                name: user.name,
                primary_email: user.email,
                login_id: user.login_id,
                avatar_url: user.avatar_url?.rawValue,
                pronouns: user.pronouns
            )

        }
        addApiRoute(GetWebSessionRequest(to: nil)) { [baseUrl] _, request in
            let returnTo = request.firstQueryParam(named: "return_to")
            return .init(session_url: returnTo.flatMap { URL(string: $0) } ?? baseUrl)
        }

        addRoute("/users/self") { _, _ in .ok(.htmlBody("")) }
        addApiRoute(GetBrandVariablesRequest()) { state, _ in state.brandVariables }
        addApiRoute(GetConversationsUnreadCountRequest()) { state, _ in
            .init(unread_count: state.unreadCount)
        }

        addApiRoute(GetCoursesRequest()) { state, _ in state.courses }
        addApiRoute(GetCourseRequest(courseID: ":courseID")) { state, request in
            state.course(byId: request.params[":courseID"]!)
        }
        addApiRoute(GetAccountNotificationsRequest()) { state, _ in state.accountNotifications }

        addApiRoute(GetCustomColorsRequest()) { state, _ in .init(custom_colors: state.customColors) }
//        addApiRoute(GetEnrollmentsRequest(context: ContextModel.currentUser)) { _ in
//        }
    }

    deinit {
        NotificationCenter.default.post(name: .init("miniCanvasServerStop"), object: baseUrl)
    }

    private static func createServer() -> MiniCanvasServer {
        for port: UInt16 in (8000 as UInt16)...8100 {
            if let server = try? MiniCanvasServer(port: port) {
                return server
            }
        }
        fatalError("Couldn't find port")
    }
}
