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

enum ServerError: Error {
    case responseError(HttpResponse)

    public static var internalServerError: ServerError { .responseError(.internalServerError) }
    public static var notFound: ServerError { .responseError(.notFound) }
    public static var unauthorized: ServerError { .responseError(.unauthorized) }
    public static var badRequest: ServerError { .responseError(.badRequest(nil)) }
}

public class MiniCanvasServer {
    public static let shared = MiniCanvasServer.createServer()
    public let server: LoggingHttpServer

    public let port: UInt16
    public let address = "localhost"
    public var host: String { "\(address):\(port)" }
    public var baseUrl: URL { URL(string: "http://\(host)/")! }

    public var state: MiniCanvasState

    private var expectationHooks: [String: MiniCanvasExpectation] = [:]

    private var graphQLRequests: [String: (APIRequest<Data>) throws -> HttpResponse] = [:]

    public struct APIRequest<Body> {
        public let server: MiniCanvasServer
        public let httpRequest: HttpRequest
        public let rawBody: Data
        public let body: Body
        public var state: MiniCanvasState { server.state }
        public var baseUrl: URL { server.baseUrl }

        public func firstQueryParam(named name: String) -> String? {
            httpRequest.queryParams.first(where: { $0.0 == name })?.1.removingPercentEncoding
        }

        public func allQueryParams(named name: String) -> [String] {
            httpRequest.queryParams.compactMap { (paramName, value) in paramName == name ? value.removingPercentEncoding : nil }
        }

        public subscript(_ name: String) -> String? {
            httpRequest.params[name] ?? firstQueryParam(named: name)
        }

        public func mapBody<T>(_ transform: (Body) throws -> T) rethrows -> APIRequest<T> {
            APIRequest<T>(server: server, httpRequest: httpRequest, rawBody: rawBody, body: try transform(body))
        }

        public func firstMultiPartParam(named name: String) -> String? {
            if let part = httpRequest.parseMultiPartFormData().first(where: { $0.name == name }) {
                return String(bytes: part.body, encoding: .utf8)
            }
            return nil
        }
    }

    public enum Endpoint {
        case graphQL(
            operationName: String,
            handler: (APIRequest<Data>) throws -> HttpResponse
        )
        case rest(
            routeTemplate: String,
            method: APIMethod,
            handler: (APIRequest<Data>) throws -> HttpResponse
        )

        // expects a requestable with a path including path parameters like "courses/:courseID"
        public static func apiRequest<R: APIRequestable>(
            _ routeRequest: R,
            handler: @escaping (APIRequest<R.Body?>) throws -> R.Response?
        ) -> Endpoint where R.Body: Decodable {
            let urlRequest = try! routeRequest.urlRequest(relativeTo: URL(string: "/")!, accessToken: "", actAsUserID: "")
            return .rest(urlRequest.url!.path, method: routeRequest.method) { request in
                let request = request.mapBody { try? APIJSONDecoder().decode(R.Body.self, from: $0) }
                guard let response = try handler(request) else {
                    return .notFound
                }
                return .json(data: try routeRequest.encode(response: response))
            }
        }

        public static func rest(
            _ template: String,
            method: APIMethod = .get,
            handler: @escaping (APIRequest<Data>) throws -> HttpResponse
        ) -> Endpoint {
            rest(routeTemplate: template, method: method, handler: handler)
        }

        public static func graphQLAny(
            operationName: String,
            handler: @escaping (APIRequest<[String: Any]>) throws -> [String: Any]
        ) -> Endpoint {
            .graphQL(operationName: operationName) { request in
                guard let body = try JSONSerialization.jsonObject(with: request.body) as? [String: Any] else {
                    print("body not valid JSON")
                    throw ServerError.badRequest
                }
                let response = try handler(request.mapBody { _ in body })
                return .json(data: try JSONSerialization.data(withJSONObject: response))
            }
        }

        public static func graphQL<R: APIGraphQLRequestable>(
            _: R.Type,
            handler: @escaping (APIRequest<R.Body>) throws -> R.Response
        ) -> Endpoint where R.Body: Decodable {
            .graphQL(operationName: R.operationName) { request in
                .json(try handler(request.mapBody { try APIJSONDecoder().decode(R.Body.self, from: $0) }))
            }
        }
    }

    public func expectationForRequest(_ path: String, method: APIMethod = .get) -> MiniCanvasExpectation {
        let expectation = MiniCanvasExpectation(description: "waiting for \(method.rawValue.uppercased()) \(path)")
        expectationHooks[path] = expectation
        return expectation
    }

    public func expectationFor<R: APIRequestable>(request: R) -> MiniCanvasExpectation {
        let urlRequest = try! request.urlRequest(relativeTo: URL(string: "/")!, accessToken: "", actAsUserID: "")
        return expectationForRequest(urlRequest.url!.path, method: request.method)
    }

    public func reset() {
        state = MiniCanvasState(baseUrl: baseUrl)
        expectationHooks = [:]
    }

    private func install(endpoint: Endpoint) {
        switch endpoint {
        case let .graphQL(operationName, handler):
            graphQLRequests[operationName] = handler
        case let .rest(routeTemplate, method, handler):
            var methodRoute: HttpServer.MethodRoute
            switch method {
            case .delete: methodRoute = server.DELETE
            case .get: methodRoute = server.GET
            case .post: methodRoute = server.POST
            case .put: methodRoute = server.PUT
            case .head: methodRoute = server.HEAD
            }
            methodRoute[routeTemplate] = { [weak self] httpRequest in
                guard let self = self else { return .internalServerError }
                do {
                    let body = Data(httpRequest.body)
                    return try handler(APIRequest(server: self, httpRequest: httpRequest, rawBody: body, body: body))
                } catch ServerError.responseError(let response) {
                    print("responseError: \(response)")
                    return response
                } catch let error {
                    print("internal server error: \(error)")
                    return HttpResponse.internalServerError
                }
            }
        }
    }

    public init(port: UInt16) throws {
        server = LoggingHttpServer()
        server.listenAddressIPv6 = "::1"
        try server.start(port)
        self.port = port
        state = MiniCanvasState(baseUrl: URL(string: "http://\(address):\(port)")!)
        MiniCanvasEndpoints.endpoints.forEach(install)
        install(endpoint: .rest("/api/graphql", method: .post, handler: handleGraphQL))
        server.postHandleDelegate = self
        NotificationCenter.default.post(name: .init("miniCanvasServerStart"), object: baseUrl)
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
              let operationName = body["operationName"] as? String else {
                print("expected field \"operationName\" to be present in JSON")
                throw ServerError.badRequest
        }
        guard let handler = graphQLRequests[operationName] else {
            print("No handler for graphQL request \(operationName)")
            throw ServerError.notFound
        }
        return try handler(request)
    }

    open class MiniCanvasExpectation: XCTestExpectation {
        public var lastRequest: HttpRequest?
    }
}

extension MiniCanvasServer: LoggingHttpServerDelegate {
    public func didHandle(request: HttpRequest) {
        if let hook = expectationHooks[request.path] {
            hook.lastRequest = request
            hook.fulfill()
        }
    }
}
