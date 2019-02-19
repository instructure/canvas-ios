//
// Copyright (C) 2019-present Instructure, Inc.
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

public protocol UseCase {
    associatedtype Model
    associatedtype Response: Codable
    typealias RequestCallback = (Response?, URLResponse?, Error?) -> Void

    var scope: Scope { get }
    var cacheKey: String { get }
    var ttl: TimeInterval { get }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback)
    func write(response: Response?, urlResponse: URLResponse?, to client: PersistenceClient) throws
    func getNext(from urlResponse: URLResponse) -> GetNextRequest<Response>?
}

extension UseCase {
    public var ttl: TimeInterval {
        return 60 * 60 * 2 // 2 hours
    }

    public func getNext(from urlResponse: URLResponse) -> GetNextRequest<Response>? {
        return nil
    }

    public func hasExpired(in client: PersistenceClient) -> Bool {
        var expired = true
        let predicate = NSPredicate(format: "%K == %@", #keyPath(TTL.key), cacheKey)
        if let cache: TTL = client.fetch(predicate).first {
            expired = cache.lastRefresh + ttl < Clock.now
        }
        return expired
    }

    public func updateTTL(in client: PersistenceClient) {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(TTL.key), cacheKey)
        let cache: TTL = client.fetch(predicate).first ?? client.insert()
        cache.key = cacheKey
        cache.lastRefresh = Clock.now
    }
}

public protocol APIUseCase: UseCase {
    associatedtype Request: APIRequestable
    var request: Request { get }
}

extension APIUseCase {
    public func getNext(from urlResponse: URLResponse) -> GetNextRequest<Request.Response>? {
        return request.getNext(from: urlResponse)
    }
}

extension APIUseCase where Response == Request.Response {
    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        environment.api.makeRequest(request, callback: completionHandler)
    }
}

public protocol PagedUseCase: APIUseCase {}
extension PagedUseCase where Response == Request.Response {
    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        environment.api.makeRequest(request) { response, urlResponse, error in
            if let error = error {
                completionHandler(response, urlResponse, error)
                return
            }
            environment.database.performBackgroundTask { client in
                do {
                    let all: [Model] = client.fetch(self.scope.predicate)
                    for model in all {
                        try client.delete(model)
                    }
                    try client.save()
                    completionHandler(response, urlResponse, error)
                } catch {
                    completionHandler(nil, nil, error)
                }
            }
        }
    }
}

public struct GetNextUseCase<U: UseCase>: APIUseCase {
    public typealias Model = U.Model
    public typealias Response = U.Response

    public let parent: U
    public let request: GetNextRequest<U.Response>

    public var scope: Scope {
        return parent.scope
    }

    public var cacheKey: String {
        return parent.cacheKey
    }

    public var ttl: TimeInterval {
        return 0
    }

    public func write(response: U.Response?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        try parent.write(response: response, urlResponse: urlResponse, to: client)
    }
}
