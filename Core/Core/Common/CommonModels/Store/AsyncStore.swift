//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import CoreData

public struct AsyncStore<U: UseCase> {
    internal let useCase: U
    private let offlineModeInteractor: OfflineModeInteractor?
    private let context: NSManagedObjectContext
    private let environment: AppEnvironment
    private let request: NSFetchRequest<U.Model>

    public init(
        offlineModeInteractor: OfflineModeInteractor? = OfflineModeAssembly.make(),
        context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext,
        useCase: U,
        environment: AppEnvironment = .shared
    ) {
        self.offlineModeInteractor = offlineModeInteractor
        self.useCase = useCase.modified(for: environment)
        self.context = context
        self.environment = environment

        request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        let scope = useCase.scope
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order
    }

    /// Produces one entity for the given UseCase.
    /// When the device is connected to the internet and there's no valid cache, it makes a request to the API and saves the response to the database. If there's valid cache, it returns it.
    /// By default it downloads all pages, and validates cache unless specificied differently.
    /// When the device is offline, it will read data from Core Data.
    /// - Parameters:
    ///     - ignoreCache: Indicates if the request should check the available cache first.
    ///       If it's set to **false**, it will validate the cache's expiration and return it if it's still valid. If the cache has expired it will make a request to the API.
    ///       If it's set to **true**, it will make a request to the API.
    ///       Defaults to **false**.
    ///     - loadAllPages: Tells the request if it should load all the pages or just the first one. Defaults to **true**.
    ///     - assertOnlyOneEntityFound: Indicates if the request should assert that only one entity is found. Defaults to **true**.
    /// - Returns: The first fetched entity.
    /// - Throws: `AsyncStoreError.noEntityFound` if no entity is found.
    /// - Throws: `AsyncStoreError.moreThanOneEntityFound` if more than one entity is found and `assertOnlyOneEntityFound` is set to true or emitted.
    public func getFirstEntity(ignoreCache: Bool = false, loadAllPages: Bool = true, assertOnlyOneEntityFound: Bool = true) async throws -> U.Model {
        let entities = try await getEntities(ignoreCache: ignoreCache, loadAllPages: loadAllPages)

        if assertOnlyOneEntityFound, entities.count > 1 { throw AsyncStoreError.moreThanOneEntityFound(entities.count) }
        guard let entity = entities.first else { throw AsyncStoreError.noEntityFound }

        return entity
    }

    /// Produces a list of entities for the given UseCase.
    /// When the device is connected to the internet and there's no valid cache, it makes a request to the API and saves the response to the database. If there's valid cache, it returns it.
    /// By default it downloads all pages, and validates cache unless specificied differently.
    /// When the device is offline, it will read data from Core Data.
    /// - Parameters:
    ///     - ignoreCache: Indicates if the request should check the available cache first.
    ///       If it's set to **false**, it will validate the cache's expiration and return it if it's still valid. If the cache has expired it will make a request to the API.
    ///       If it's set to **true**, it will make a request to the API.
    ///       Defaults to **false**.
    ///     - loadAllPages: Tells the request if it should load all the pages or just the first one. Defaults to **true**.
    /// - Returns: A list of entities.
    public func getEntities(ignoreCache: Bool = false, loadAllPages: Bool = true) async throws -> [U.Model] {
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            return try await fetchEntitiesFromDatabase()
        } else {
            let hasExpired = await useCase.hasCacheExpired(environment: environment)

            if ignoreCache || hasExpired {
                return try await fetchEntitiesFromAPI(loadAllPages: loadAllPages)
            } else {
                return try await fetchEntitiesFromDatabase()
            }
        }
    }

    /// Produces an async sequence of entities for the given UseCase keeping track of database changes.
    /// When the device is connected to the internet and there's no valid cache, it makes a request to the API and saves the response to the database. If there's valid cache, it returns it.
    /// By default it downloads all pages, and validates cache unless specificied differently.
    /// When the device is offline, it will read data from Core Data.

    /// - Warning: This stream **does not terminate**. Ensure proper cancellation of its consuming task.
    /// - Parameters:
    ///     - ignoreCache: Indicates if the request should check the available cache first.
    ///       If it's set to **false**, it will validate the cache's expiration and return it if it's still valid. If the cache has expired it will make a request to the API.
    ///       If it's set to **true**, it will make a request to the API.
    ///       Defaults to **false**.
    ///     - loadAllPages: Tells the request if it should load all the pages or just the first one. Defaults to **true**.
    /// - Returns: An async sequence of list of entities.
    public func updates(ignoreCache: Bool = false, loadAllPages: Bool = true) async throws -> AsyncThrowingStream<[U.Model], Error> {
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            return streamEntitiesFromDatabase()
        } else {
            let hasExpired = await useCase.hasCacheExpired(environment: environment)

            if ignoreCache || hasExpired {
                try await updateEntitiesFromAPI(loadAllPages: loadAllPages)
            }

            return streamEntitiesFromDatabase()
        }
    }

    public func getEntitiesFromDatabase() async throws -> [U.Model] {
        try await fetchEntitiesFromDatabase()
    }

    /// - Warning: This stream **does not terminate**. Ensure proper cancellation of its consuming task.
    public func updatesFromDatabase() -> AsyncThrowingStream<[U.Model], Error> {
        streamEntitiesFromDatabase()
    }

    /// Refreshes the entities by requesting the latest data from the API.
    public func forceRefresh(loadAllPages: Bool = true) async {
        _ = try? await getEntities(ignoreCache: true, loadAllPages: loadAllPages)
    }

    private func fetchEntitiesFromAPI(getNextUseCase: GetNextUseCase<U>? = nil, loadAllPages: Bool) async throws -> [U.Model] {
        let urlResponse = try await {
                if let getNextUseCase {
                    try await getNextUseCase.fetch(environment: environment)
                } else {
                    try await useCase.fetch(environment: environment)
                }
        }()

        let nextResponse = urlResponse.flatMap { useCase.getNext(from: $0) }
        try await fetchAllPagesIfNeeded(loadAllPages: loadAllPages, nextResponse: nextResponse)

        return try await fetchEntitiesFromDatabase()
    }

    private func updateEntitiesFromAPI(getNextUseCase: GetNextUseCase<U>? = nil, loadAllPages: Bool) async throws {
        let urlResponse = try await {
                if let getNextUseCase {
                    try await getNextUseCase.fetch(environment: environment)
                } else {
                    try await useCase.fetch(environment: environment)
                }
        }()

        let nextResponse = urlResponse.flatMap { useCase.getNext(from: $0) }
        try await fetchAllPagesIfNeeded(loadAllPages: loadAllPages, nextResponse: nextResponse)
    }

    private func fetchAllPagesIfNeeded(loadAllPages: Bool, nextResponse: GetNextRequest<U.Response>?) async throws {
        guard loadAllPages else { return }
        let nextPageUseCase = getNextPage(nextResponse: nextResponse)

        if let nextPageUseCase {
            _ = try await fetchEntitiesFromAPI(getNextUseCase: nextPageUseCase, loadAllPages: true)
        }
    }

    private func getNextPage(nextResponse: GetNextRequest<U.Response>?) -> GetNextUseCase<U>? {
        if let nextResponse {
            GetNextUseCase(parent: useCase, request: nextResponse)
        } else {
            nil
        }
    }

    private func fetchEntitiesFromDatabase() async throws -> [U.Model] {
        try await AsyncFetchedResults(request: request, context: context)
            .fetch()
    }

    private func streamEntitiesFromDatabase() -> AsyncThrowingStream<[U.Model], Error> {
        AsyncFetchedResults(request: request, context: context)
            .stream()
    }
}

public enum AsyncStoreError: Error, Equatable {
    case noEntityFound
    case moreThanOneEntityFound(Int)
}
