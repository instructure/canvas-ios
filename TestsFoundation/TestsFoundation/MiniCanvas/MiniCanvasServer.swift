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
        let data: Data
        do {
            data = try encoder.encode(encodable)
        } catch let e {
            print("internal server error: encoding \(E.self) failed: \(e)")
            return .internalServerError
        }
        return .raw(200, "OK", [HttpHeader.contentType: "application/json"]) { writer in
            try writer.write(data)
        }
    }
}

class MockWriter: HttpResponseBodyWriter {
    var data = Data()

    func write(_ file: String.File) throws { }
    func write(_ data: [UInt8]) throws { }
    func write(_ data: ArraySlice<UInt8>) throws { }
    func write(_ data: NSData) throws { }
    func write(_ data: Data) throws { self.data = data }
}

public class LoggingHttpServer: HttpServer {
    public var logResponses: Bool = false

    public override func dispatch(_ request: HttpRequest) -> ([String: String], (HttpRequest) -> HttpResponse) {
        let (params, handler) = super.dispatch(request)
        return (params, { [weak self] request in
            let response = handler(request)
            var queryString = ""
            if !request.queryParams.isEmpty {
                queryString = " \(request.queryParams)"
            }
            let alert = response.statusCode < 400 ? "" : " ❌"
            var log = "\(request.method) \(request.path)\(queryString) \(response.statusCode)\(alert)"
            if self?.logResponses == true {
                if case HttpResponse.raw(_, _, _, let body) = response {
                    let writer = MockWriter()
                    try? body?(writer)
                    let bodyData = writer.data
                    if let bodyStr = String(data: bodyData, encoding: .utf8) {
                        log += "\n\(bodyStr)"
                    } else {
                        log += "\n\(bodyData)"
                    }
                }
            }
            DispatchQueue.main.async {
                print(log)
            }
            return response
        })
    }
}

public class MiniCanvasServer {
    public static let shared = MiniCanvasServer.createServer()
    public let server: LoggingHttpServer

    public let port: UInt16
    public let address = "localhost"
    public var host: String { "\(address):\(port)" }
    public var baseUrl: URL { URL(string: "http://\(host)/")! }

    public var state = MiniCanvasState()
    public func reset() {
        state = MiniCanvasState()
    }
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    enum APIError: Error {
        case responseError(HttpResponse)

        public static var internalServerError: APIError { .responseError(.internalServerError) }
        public static var notFound: APIError { .responseError(.notFound) }
        public static var unauthorized: APIError { .responseError(.unauthorized) }
        public static var badRequest: APIError { .responseError(.badRequest(nil)) }
    }

    func addRoute(
        _ route: String,
        method: APIMethod = .get,
        handler: @escaping (APIRequest<Data>) throws -> HttpResponse
    ) {
        var methodRoute: HttpServer.MethodRoute
        switch method {
        case .delete: methodRoute = server.DELETE
        case .get: methodRoute = server.GET
        case .post: methodRoute = server.POST
        case .put: methodRoute = server.PUT
        }
        // capture state instead of self to avoid retain cycles
        methodRoute[route] = { [state] httpRequest in
            do {
                return try handler(APIRequest(state: state, httpRequest: httpRequest, body: Data(httpRequest.body)))
            } catch APIError.responseError(let response) {
                return response
            } catch let error {
                print("internal server error: \(error)")
                return HttpResponse.internalServerError
            }
        }
    }

    public struct APIRequest<Body: Codable> {
        public let state: MiniCanvasState
        public let httpRequest: HttpRequest
        public let body: Body

        public func firstQueryParam(named name: String) -> String? {
            httpRequest.queryParams.first(where: { $0.0 == name })?.1
        }

        public func allQueryParams(named name: String) -> [String] {
            httpRequest.queryParams.compactMap { (paramName, value) in paramName == name ? value : nil }
        }

        public subscript(_ name: String) -> String? {
            httpRequest.params[name] ?? firstQueryParam(named: name)
        }

        public func mapBody<T: Codable>(_ transform: (Body) throws -> T) rethrows -> APIRequest<T> {
            APIRequest<T>(state: state, httpRequest: httpRequest, body: try transform(body))
        }
    }

    // expects a requestable with a path including path parameters like "courses/:courseID"
    func addApiRoute<R: APIRequestable>(
        _ routeRequest: R,
        handler: @escaping (APIRequest<R.Body?>) throws -> R.Response?
    ) {
        let urlRequest = try! routeRequest.urlRequest(relativeTo: baseUrl, accessToken: "", actAsUserID: "")
        addRoute(urlRequest.url!.path, method: routeRequest.method) { request in
            let request = request.mapBody { try? Self.jsonDecoder.decode(R.Body.self, from: $0) }
            guard let response = try handler(request) else {
                return .notFound
            }
            return .json(response)
        }
    }

    private var graphQLRequests: [String: (APIRequest<Data>) throws -> HttpResponse] = [:]

    func addGraphQLQuery<R: APIGraphQLRequestable>(_ : R.Type, handler: @escaping (APIRequest<R.Body>) throws -> R.Response) {
        graphQLRequests[R.operationName] = { request in
            .json(try handler(request.mapBody { try Self.jsonDecoder.decode(R.Body.self, from: $0) }))
        }
    }

    public init(port: UInt16) throws {
        server = LoggingHttpServer()
        server.listenAddressIPv6 = "::1"
        try server.start(port)
        self.port = port
        installRoutes()
        NotificationCenter.default.post(name: .init("miniCanvasServerStart"), object: baseUrl)
    }

    private func installRoutes() {
        let verifyClient = APIVerifyClient(authorized: true, base_url: baseUrl, client_id: "i dunno", client_secret: "lol")
        addApiRoute(GetMobileVerifyRequest(domain: "")) { _ in verifyClient }

        // https://canvas.instructure.com/doc/api/file.oauth_endpoints.html
        addRoute("/login/oauth2/auth") { request in
            guard let redirectUri = request.firstQueryParam(named: "redirect_uri" ) else {
                return .badRequest(nil)
            }
            // login always works
            return .movedTemporarily("\(redirectUri)?code=t")
        }
        addApiRoute(PostLoginOAuthRequest(client: verifyClient, code: "")) { request in
            return APIOAuthToken.make(user: .from(user: request.state.selfUser))
        }
        addApiRoute(GetUserProfileRequest(userID: ":userID")) { request in
            var userID = request[":userID"]!
            if userID == "self" {
                userID = request.state.selfId
            }
            guard let user = request.state.user(byId: userID) else { return nil }
            return APIProfile.make(
                id: user.id,
                name: user.name,
                primary_email: user.email,
                login_id: user.login_id,
                avatar_url: user.avatar_url?.rawValue,
                pronouns: user.pronouns
            )
        }

        addApiRoute(GetWebSessionRequest(to: nil)) { [baseUrl] request in
            .init(session_url: request["return_to"].flatMap { URL(string: $0) } ?? baseUrl)
        }

        addRoute("/users/self") { _ in .ok(.htmlBody("")) }
        addApiRoute(GetBrandVariablesRequest()) { request in request.state.brandVariables }
        addApiRoute(GetConversationsUnreadCountRequest()) { request in
            .init(unread_count: request.state.unreadCount)
        }

        addApiRoute(GetCoursesRequest()) { request in request.state.courses.map { $0.api } }
        addApiRoute(GetCourseRequest(courseID: ":courseID")) { request in
            request.state.course(byId: request[":courseID"]!)?.api
        }
        addApiRoute(GetAccountNotificationsRequest()) { request in request.state.accountNotifications }
        addApiRoute(DeleteAccountNotificationRequest(id: ":id")) { request in
            let id = ID(request[":id"]!)
            request.state.accountNotifications.removeAll(where: { $0.id == id })
            return APINoContent()
        }

        addApiRoute(GetCustomColorsRequest()) { request in .init(custom_colors: request.state.customColors) }
        addRoute("/api/v1/users/self/colors/:id", method: .put) { request in
            let body = try JSONDecoder().decode(UpdateCustomColorRequest.Body.self, from: Data(request.body))
            request.state.customColors[request[":id"]!] = body.hexcode
            return .accepted
        }

        addApiRoute(GetEnrollmentsRequest(context: ContextModel.currentUser)) { request in
            request.state.userEnrollments()
        }
        addApiRoute(GetDashboardCardsRequest()) { request in
            try request.state.userEnrollments().compactMap { enrollment in
                guard let course = request.state.course(byId: enrollment.course_id!)?.api else {
                    throw APIError.notFound
                }
                guard request.state.favoriteCourses.contains(course.id) else { return nil }
                return APIDashboardCard.make(
                    assetString: course.canvasContextID,
                    courseCode: course.course_code!,
                    enrollmentType: enrollment.type,
                    href: "/courses/\(course.id)",
                    id: course.id,
                    longName: course.name!,
                    originalName: course.name!,
                    position: Int(course.id),
                    shortName: course.name!
                )
            }
        }
        addApiRoute(GetUserSettingsRequest(userID: "self")) { _ in .make() }
        addRoute("/api/v1/users/self/custom_data/favorites/groups") { _ in .json([String: String]()) }
        addApiRoute(GetGroupsRequest(context: ContextModel.currentUser)) { _ in [] }
        addApiRoute(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"))) { _ in .make() }

        let courseRouteContext = ContextModel(.course, id: ":courseID")
        addApiRoute(GetTabsRequest(context: courseRouteContext)) { request in
            request.state.course(byId: request[":courseID"]!)?.tabs
        }

        addApiRoute(GetContextPermissionsRequest(context: courseRouteContext)) { request in
            guard let course = request.state.course(byId: request[":courseID"]!) else {
                throw APIError.notFound
            }
            let permissions = course.api.permissions ?? APICourse.Permissions(create_announcement: false, create_discussion_topic: false)
            return try JSONDecoder().decode(APIPermissions.self, from: JSONEncoder().encode(permissions))
        }
        addApiRoute(GetExternalToolsRequest(context: courseRouteContext, includeParents: false)) { request in
            request.state.course(byId: request[":courseID"]!)?.externalTools
        }

        addRoute("/api/graphql", method: .post) { [weak self] request in
            guard let self = self else {
                throw APIError.internalServerError
            }
            return try self.handleGraphQL(request: request)
        }

        addGraphQLQuery(AssignmentListRequestable.self) { request in
            let vars = request.body.variables
            guard let course = request.state.course(byId: vars.courseID) else {
                throw APIError.notFound
            }

            let assignments: [APIAssignmentListAssignment] = course.assignments.map { assignment in
                APIAssignmentListAssignment.make(
                    id: assignment.id,
                    name: assignment.name,
                    dueAt: assignment.due_at,
                    lockAt: assignment.lock_at,
                    unlockAt: assignment.unlock_at,
                    htmlUrl: "\(assignment.html_url)",
                    submissionTypes: assignment.submission_types,
                    quizID: assignment.quiz_id
                )
            }

            return APIAssignmentListResponse.make(gradingPeriods: [], groups: [.make(assignments: assignments)])
        }
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

    private func handleGraphQL(request: APIRequest<Data>) throws -> HttpResponse {
        guard let body = try? JSONSerialization.jsonObject(with: request.body) as? [String: Any],
              let operationName = body["operationName"] as? String,
              let handler = graphQLRequests[operationName] else {
            throw APIError.badRequest
        }
        return try handler(request)
    }
}
