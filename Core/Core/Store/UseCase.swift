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
import CoreData

public protocol UseCase {
    associatedtype Model: NSManagedObject = NSManagedObject
    associatedtype Response: Codable
    typealias RequestCallback = (Response?, URLResponse?, Error?) -> Void

    var scope: Scope { get }
    var cacheKey: String? { get }
    var ttl: TimeInterval { get }
    var clearsBeforeWrite: Bool { get }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback)
    func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext)
    func getNext(from response: URLResponse) -> GetNextRequest<Response>?
}

extension UseCase {
    public var scope: Scope {
        return Scope.all(orderBy: "id")
    }

    public var ttl: TimeInterval {
        return 60 * 60 * 2 // 2 hours
    }

    public var clearsBeforeWrite: Bool {
        return false
    }

    public func getNext(from response: URLResponse) -> GetNextRequest<Response>? {
        return nil
    }

    public func hasExpired(in client: NSManagedObjectContext) -> Bool {
        guard let cacheKey = cacheKey else { return true }
        var expired = true
        let predicate = NSPredicate(format: "%K == %@", #keyPath(TTL.key), cacheKey)
        if let cache: TTL = client.fetch(predicate).first {
            expired = cache.lastRefresh + ttl < Clock.now
        }
        return expired
    }

    public func updateTTL(in client: NSManagedObjectContext) {
        guard let cacheKey = cacheKey else { return }
        let predicate = NSPredicate(format: "%K == %@", #keyPath(TTL.key), cacheKey)
        let cache: TTL = client.fetch(predicate).first ?? client.insert()
        cache.key = cacheKey
        cache.lastRefresh = Clock.now
    }

    public func fetch(environment: AppEnvironment = .shared, force: Bool = false, _ callback: @escaping RequestCallback) {
        // Make sure we write to the database that initiated this request
        let database = environment.database
        database.performBackgroundTask { client in
            guard force || self.hasExpired(in: client) else {
                callback(nil, nil, nil) // FIXME: Return cached data?
                return
            }
            self.makeRequest(environment: environment) { response, urlResponse, error in
                if let error = error {
                    callback(response, urlResponse, error)
                    return
                }
                database.performBackgroundTask { client in
                    do {
                        if self.clearsBeforeWrite {
                            let all: [Model] = client.fetch(self.scope.predicate)
                            client.delete(all)
                        }
                        self.write(response: response, urlResponse: urlResponse, to: client)
                        self.updateTTL(in: client)
                        try client.save()
                        callback(response, urlResponse, error)
                    } catch {
                        callback(response, urlResponse, error)
                    }
                }
            }
        }
    }
}

public protocol APIUseCase: UseCase {
    associatedtype Request: APIRequestable
    var request: Request { get }
}

extension APIUseCase {
    public func getNext(from response: URLResponse) -> GetNextRequest<Request.Response>? {
        return request.getNext(from: response)
    }
}

extension APIUseCase where Response == Request.Response {
    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        environment.api.makeRequest(request, callback: completionHandler)
    }
}

public protocol CollectionUseCase: APIUseCase {}
extension CollectionUseCase where Response == Request.Response {
    public var clearsBeforeWrite: Bool {
        return true
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

    public var cacheKey: String? {
        return parent.cacheKey
    }

    public var ttl: TimeInterval {
        return 0
    }

    public func write(response: U.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        parent.write(response: response, urlResponse: urlResponse, to: client)
    }
}

public protocol WriteableModel {
    associatedtype JSON

    @discardableResult
    static func save(_ item: JSON, in context: NSManagedObjectContext) -> Self

    @discardableResult
    static func save(_ items: [JSON], in context: NSManagedObjectContext) -> [Self]
}

extension WriteableModel {
    @discardableResult
    public static func save(_ items: [JSON], in context: NSManagedObjectContext) -> [Self] {
        return items.map { save($0, in: context) }
    }
}

extension UseCase where Model: WriteableModel, Model.JSON == Response {
    public func write(response: Model.JSON?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }
        Model.save(response, in: client)
    }
}

extension UseCase where Model: WriteableModel, Response: Collection, Model.JSON == Response.Element {
    public func write(response: [Model.JSON]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }
        Model.save(response, in: client)
    }
}

public struct LocalUseCase<T>: UseCase where T: NSManagedObject {
    public typealias Model = T
    // Response doesn't matter so this is just a Codable stub
    public typealias Response = Int

    public let scope: Scope

    public var cacheKey: String?

    public init(scope: Scope) {
        self.scope = scope
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Int?, URLResponse?, Error?) -> Void) {
        completionHandler(1, nil, nil)
    }

    public func write(response: Int?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {}
}
