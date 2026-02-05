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

public enum AsyncStoreError: Error, Equatable {
    case noEntityFound
    case moreThanOneEntityFound(Int)
}

public struct AsyncStore<U: UseCase> {
    private let useCase: U
    private let request: NSFetchRequest<U.Model>

    private let context: NSManagedObjectContext
    private let offlineModeInteractor: OfflineModeInteractor?
    private let environment: AppEnvironment

    private var isOfflineModeEnabled: Bool {
        offlineModeInteractor?.isOfflineModeEnabled() ?? false
    }

    public init(
        useCase: U,
        context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext,
        offlineModeInteractor: OfflineModeInteractor? = OfflineModeAssembly.make(),
        environment: AppEnvironment = .shared
    ) {
        self.useCase = useCase.modified(for: environment)

        self.request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        let scope = useCase.scope
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order

        self.context = context
        self.offlineModeInteractor = offlineModeInteractor
        self.environment = environment
    }

    // MARK: - Get Entities

    /// Produces a list of entities for the given UseCase.
    ///
    /// When the device is connected to the internet and there's no valid cache,
    /// it makes a request to the API and saves the response to the database.
    /// If there's valid cache, it returns it.
    /// By default it downloads all pages, and validates cache unless specificied differently.
    /// When the device is offline, it will read data from Core Data.
    ///
    /// - Parameters:
    ///     - ignoreCache: Indicates if the request should check the available cache first.
    ///       If it's set to **false**, it will validate the cache's expiration and return it if it's still valid.
    ///       If the cache has expired it will make a request to the API.
    ///       If it's set to **true**, it will make a request to the API.
    ///       Defaults to **false**.
    ///     - loadAllPages: Tells the request if it should load all the pages or just the first one. Defaults to **true**.
    /// - Returns: A list of entities.
    public func getEntities(ignoreCache: Bool = false, loadAllPages: Bool = true) async throws -> [U.Model] {
        if isOfflineModeEnabled {
            return try await getEntitiesFromDatabase()
        }

        let hasExpired = await useCase.hasCacheExpired(environment: environment)

        if ignoreCache || hasExpired {
            try await fetchEntitiesFromAPI(loadAllPages: loadAllPages)
        }

        return try await getEntitiesFromDatabase()
    }

    /// Produces one non-optional entity for the given UseCase.
    /// Use this variant when the single entity should exist, we just need to fetch it.
    ///
    /// When the device is connected to the internet and there's no valid cache,
    /// it makes a request to the API and saves the response to the database.
    /// If there's valid cache, it returns it.
    /// By default it downloads all pages, and validates cache unless specificied differently.
    /// When the device is offline, it will read data from Core Data.
    ///
    /// - Parameters:
    ///     - ignoreCache: Indicates if the request should check the available cache first.
    ///       If it's set to **false**, it will validate the cache's expiration and return it if it's still valid.
    ///       If the cache has expired it will make a request to the API.
    ///       If it's set to **true**, it will make a request to the API.
    ///       Defaults to **false**.
    ///     - loadAllPages: Tells the request if it should load all the pages or just the first one. Defaults to **true**.
    ///     - assertOnlyOneEntityFound: Indicates if the request should assert that only one entity is found. Defaults to **true**.
    /// - Returns: The first fetched entity.
    /// - Throws: `AsyncStoreError.noEntityFound` if no entity is found.
    /// - Throws: `AsyncStoreError.moreThanOneEntityFound` if more than one entity is found and `assertOnlyOneEntityFound` is set to true.
    public func getSingleEntity(
        ignoreCache: Bool = false,
        loadAllPages: Bool = true,
        assertOnlyOneEntityFound: Bool = true
    ) async throws -> U.Model {
        let entities = try await getEntities(ignoreCache: ignoreCache, loadAllPages: loadAllPages)

        if assertOnlyOneEntityFound, entities.count > 1 {
            throw AsyncStoreError.moreThanOneEntityFound(entities.count)
        }

        guard let entity = entities.first else {
            throw AsyncStoreError.noEntityFound
        }

        return entity
    }

    public func getEntitiesFromDatabase() async throws -> [U.Model] {
        try await AsyncFetchedResults(request: request, context: context)
            .fetch()
    }

    // MARK: - Stream Entities

    /// Produces an async sequence of entities for the given UseCase keeping track of database changes.
    ///
    /// - Warning: This stream **DOES NOT terminate**. Ensure proper cancellation of its consuming task.
    ///
    /// When the device is connected to the internet and there's no valid cache,
    /// it makes a request to the API and saves the response to the database.
    /// If there's valid cache, it returns it.
    /// By default it downloads all pages, and validates cache unless specificied differently.
    /// When the device is offline, it will read data from Core Data.
    ///
    /// - Parameters:
    ///     - ignoreCache: Indicates if the request should check the available cache first.
    ///       If it's set to **false**, it will validate the cache's expiration and return it if it's still valid.
    ///       If the cache has expired it will make a request to the API.
    ///       If it's set to **true**, it will make a request to the API.
    ///       Defaults to **false**.
    ///     - loadAllPages: Tells the request if it should load all the pages or just the first one. Defaults to **true**.
    /// - Returns: An async sequence of list of entities.
    public func streamEntities(
        ignoreCache: Bool = false,
        loadAllPages: Bool = true
    ) async throws -> AsyncThrowingStream<[U.Model], Error> {
        if isOfflineModeEnabled {
            return streamEntitiesFromDatabase()
        }

        let hasExpired = await useCase.hasCacheExpired(environment: environment)

        if ignoreCache || hasExpired {
            try await fetchEntitiesFromAPI(loadAllPages: loadAllPages)
        }

        return streamEntitiesFromDatabase()
    }

    /// - Warning: This stream **DOES NOT terminate**. Ensure proper cancellation of its consuming task.
    public func streamEntitiesFromDatabase() -> AsyncThrowingStream<[U.Model], Error> {
        AsyncFetchedResults(request: request, context: context)
            .stream()
    }

    // MARK: - Force Refresh

    /// Refetches the entities from the API and stores the updated data in the local database.
    /// Does not return the entities themselves.
    /// Throws any fetching errors, allowing the caller to decide whether to silence them or to handle them.
    public func forceRefresh(loadAllPages: Bool = true) async throws {
        if !isOfflineModeEnabled {
            try await fetchEntitiesFromAPI(loadAllPages: loadAllPages)
        }
    }

    // MARK: - Fetch API (private)

    /// Fetches the entities from the API and stores them in the local database.
    /// Does not return the entities themselves.
    private func fetchEntitiesFromAPI(
        getNextUseCase: GetNextUseCase<U>? = nil,
        loadAllPages: Bool
    ) async throws {
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
        guard let nextResponse, loadAllPages else { return }
        let nextPageUseCase = GetNextUseCase(parent: useCase, request: nextResponse)

        try await fetchEntitiesFromAPI(getNextUseCase: nextPageUseCase, loadAllPages: true)
    }
}
