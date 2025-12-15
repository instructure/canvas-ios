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

public protocol AsyncAPIUseCases: UseCase {
    func makeRequest(environment: AppEnvironment) async throws -> (Response, URLResponse?)
}

public protocol AsyncUseCase: UseCase {
    func makeRequest(environment: AppEnvironment) async throws -> (Response, URLResponse?)
}

public extension AsyncUseCase {
    func hasCacheExpired(environment: AppEnvironment = .shared) async throws -> Bool {
        try await environment.database.performWriteTask { context in
            self.hasExpired(in: context)
        }
    }

    func fetch(environment: AppEnvironment = .shared) async throws -> URLResponse? {
        try await executeFetch(environment: environment).1
    }

    private func executeFetch(environment: AppEnvironment) async throws -> (Response, URLResponse?) {
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

public protocol AsyncAPIUseCase: AsyncUseCase, APIUseCase { }

public extension AsyncAPIUseCase where Response == Request.Response {
    func makeRequest(environment: AppEnvironment) async throws -> (Response, URLResponse?) {
        try await environment.api.makeRequest(request)
    }
}

public protocol AsyncCollectionUseCase: AsyncAPIUseCase, CollectionUseCase { }

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
