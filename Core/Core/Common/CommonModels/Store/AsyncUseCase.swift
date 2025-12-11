//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import CoreData
import Foundation

public protocol AsyncUseCase {
    associatedtype Model: NSManagedObject = NSManagedObject
    associatedtype Response: Codable

    var scope: Scope { get }
    var cacheKey: String? { get }
    var ttl: TimeInterval { get }

    func makeRequest(environment: AppEnvironment) async throws -> (Response, URLResponse)
    func reset(context: NSManagedObjectContext)
    func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext)
    func getNext(from response: URLResponse) -> GetNextRequest<Response>?
    func modified(for env: AppEnvironment) -> Self
}

public extension AsyncUseCase {
    var scope: Scope {
        return Scope.all(orderBy: "objectID")
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

    func modified(for env: AppEnvironment) -> Self {
        self
    }
}

public extension AsyncUseCase {
    /// Cache expiration check used by the legacy `Store`.
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

        /// Private helper method, used by both closure based and reactive `fetch()` methods.
    func updateTTL(in client: NSManagedObjectContext) {
        guard let cacheKey = cacheKey else { return }
        let predicate = NSPredicate(format: "%K == %@", #keyPath(TTL.key), cacheKey)
        let cache: TTL = client.fetch(predicate).first ?? client.insert()
        cache.key = cacheKey
        cache.lastRefresh = Clock.now
    }

    // Cache expiration check used by the `ReactiveStore`.
    func hasCacheExpired(environment: AppEnvironment = .shared) async throws -> Bool {
        try await environment.database.performWriteTask { context in
            self.hasExpired(in: context)
        }
    }

    /// Reactive `fetch()`, used by the `ReactiveStore` and directly from other places.
    /// Returns the URLResponse after writing to the database.
    func fetch(environment: AppEnvironment = .shared) async throws -> URLResponse {
        try await executeFetch(environment: environment).1
    }

    /// Private helper method that executes the fetch and write logic.
    private func executeFetch(environment: AppEnvironment) async throws -> (Response, URLResponse) {
        let (response, urlResponse) = try await makeRequest(environment: environment)

        return try await environment.database.performWriteTask { context in
            do {
                self.reset(context: context)
                self.write(response: response, urlResponse: urlResponse, to: context)
                self.updateTTL(in: context)
                try context.save()

                return (response, urlResponse)
            } catch let dbError {
                Logger.shared.error(dbError.localizedDescription)
                RemoteLogger.shared.logError(
                    name: "CoreData save failed",
                    reason: dbError.localizedDescription
                )
                throw dbError
            }
        }
    }
}

public protocol AsyncAPIUseCase: AsyncUseCase {
    associatedtype Request: APIRequestable
    var request: Request { get }
}

public extension AsyncAPIUseCase {
    func getNext(from response: URLResponse) -> GetNextRequest<Request.Response>? {
        return request.getNext(from: response)
    }
}

public extension AsyncAPIUseCase where Response == Request.Response {
    func makeRequest(environment: AppEnvironment) async throws -> (Response, URLResponse) {
        try await environment.api.makeRequest(request)
    }
}

public struct AsyncGetNextUseCase<U: AsyncUseCase>: AsyncAPIUseCase {
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
