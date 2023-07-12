//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import CoreData
import Foundation

public protocol UseCase {
    associatedtype Model: NSManagedObject = NSManagedObject
    associatedtype Response: Codable
    typealias RequestCallback = (Response?, URLResponse?, Error?) -> Void

    var scope: Scope { get }
    var cacheKey: String? { get }
    var ttl: TimeInterval { get }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback)
    func reset(context: NSManagedObjectContext)
    func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext)
    func getNext(from response: URLResponse) -> GetNextRequest<Response>?
}

public extension UseCase {
    var scope: Scope {
        return Scope.all(orderBy: "id")
    }

    var ttl: TimeInterval {
        return 60 * 60 * 2 // 2 hours
    }

    func getNext(from _: URLResponse) -> GetNextRequest<Response>? {
        return nil
    }

    func reset(context _: NSManagedObjectContext) {
        // no-op
    }

    func hasExpired(in client: NSManagedObjectContext) -> Bool {
        guard let cacheKey = cacheKey, !ProcessInfo.isUITest else { return true }
        var expired = true
        let predicate = NSPredicate(format: "%K == %@", #keyPath(TTL.key), cacheKey)
        if let cache: TTL = client.fetch(predicate).first,
           let lastRefresh = cache.lastRefresh {
            expired = lastRefresh + ttl < Clock.now
        }
        return expired
    }

    func updateTTL(in client: NSManagedObjectContext) {
        guard let cacheKey = cacheKey else { return }
        let predicate = NSPredicate(format: "%K == %@", #keyPath(TTL.key), cacheKey)
        let cache: TTL = client.fetch(predicate).first ?? client.insert()
        cache.key = cacheKey
        cache.lastRefresh = Clock.now
    }

    func fetch(environment: AppEnvironment = .shared, force: Bool = false, _ callback: RequestCallback? = nil) {
        // Make sure we write to the database that initiated this request
        let database = environment.database
        database.performWriteTask { client in
            guard force || self.hasExpired(in: client) else {
                callback?(nil, nil, nil) // FIXME: Return cached data?
                return
            }
            self.makeRequest(environment: environment) { response, urlResponse, error in
                if let error = error {
                    callback?(response, urlResponse, error)
                    return
                }
                database.performWriteTask { context in
                    do {
                        self.reset(context: context)
                        self.write(response: response, urlResponse: urlResponse, to: context)
                        self.updateTTL(in: context)
                        try context.save()
                        callback?(response, urlResponse, error)
                    } catch {
                        callback?(response, urlResponse, error)
                    }
                }
            }
        }
    }

    func hasCacheExpired(environment: AppEnvironment = .shared) -> Future<Bool, Never> {
        Future<Bool, Never> { promise in
            environment.database.performWriteTask { context in
                promise(.success(self.hasExpired(in: context)))
            }
        }
    }

    func fetchWithFuture(environment: AppEnvironment = .shared) -> Future<URLResponse?, Error> {
        Future<URLResponse?, Error> { promise in
            self.makeRequest(environment: environment) { response, urlResponse, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let database = environment.database
                    database.performWriteTask { context in
                        do {
                            self.reset(context: context)
                            self.write(response: response, urlResponse: urlResponse, to: context)
                            self.updateTTL(in: context)
                            try context.save()
                            promise(.success(urlResponse))
                        } catch let dbError {
                            promise(.failure(dbError))
                        }
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

public extension APIUseCase {
    func getNext(from response: URLResponse) -> GetNextRequest<Request.Response>? {
        return request.getNext(from: response)
    }
}

public extension APIUseCase where Response == Request.Response {
    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        environment.api.makeRequest(request, callback: completionHandler)
    }
}

public protocol CollectionUseCase: APIUseCase {}
public extension CollectionUseCase {
    func reset(context: NSManagedObjectContext) {
        context.delete(context.fetch(scope: scope) as [Model])
    }
}

public protocol DeleteUseCase: APIUseCase {}
public extension DeleteUseCase {
    func write(response _: Response?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        client.delete(client.fetch(scope: scope) as [Model])
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

public extension WriteableModel {
    @discardableResult
    static func save(_ items: [JSON], in context: NSManagedObjectContext) -> [Self] {
        return items.map { save($0, in: context) }
    }
}

public extension UseCase where Model: WriteableModel, Model.JSON == Response {
    func write(response: Model.JSON?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }
        Model.save(response, in: client)
    }
}

public extension UseCase where Model: WriteableModel, Response: Collection, Model.JSON == Response.Element {
    func write(response: [Model.JSON]?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }
        Model.save(response, in: client)
    }
}

public class LocalUseCase<T>: UseCase where T: NSManagedObject {
    public typealias Model = T
    // Response doesn't matter so this is just a Codable stub
    public typealias Response = Int

    public let scope: Scope

    public var cacheKey: String?

    public init(scope: Scope) {
        self.scope = scope
    }

    public func makeRequest(environment _: AppEnvironment, completionHandler: @escaping (Int?, URLResponse?, Error?) -> Void) {
        completionHandler(1, nil, nil)
    }

    public func write(response _: Int?, urlResponse _: URLResponse?, to _: NSManagedObjectContext) {}
}

public class DeleteLocalUseCase<T>: UseCase where T: NSManagedObject {
    public typealias Model = T
    // Response doesn't matter so this is just a Codable stub
    public typealias Response = Int

    public var scope: Scope

    public private(set) var cacheKey: String?

    public init(scope: Scope) {
        self.scope = scope
    }

    public func makeRequest(environment _: AppEnvironment, completionHandler: @escaping (Int?, URLResponse?, Error?) -> Void) {
        completionHandler(1, nil, nil)
    }

    public func write(response _: Response?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        client.delete(client.fetch(scope: scope) as [Model])
    }
}
