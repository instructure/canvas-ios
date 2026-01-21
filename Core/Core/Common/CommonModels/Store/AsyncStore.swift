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
    fileprivate let offlineModeInteractor: OfflineModeInteractor?
    internal let useCase: U
    fileprivate let context: NSManagedObjectContext
    fileprivate let environment: AppEnvironment

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
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order


        return if offlineModeInteractor?.isOfflineModeEnabled() == true {
            try await Self.fetchEntitiesFromDatabase(
                fetchRequest: request,
                context: context
            )
        } else {
            if ignoreCache {
                try await Self.fetchEntitiesFromAPI(
                    useCase: useCase,
                    loadAllPages: loadAllPages,
                    fetchRequest: request,
                    context: context,
                    environment: environment
                    )
            } else {
                try await Self.fetchEntitiesFromCache(
                    useCase: useCase,
                    fetchRequest: request,
                    loadAllPages: loadAllPages,
                    context: context,
                    environment: environment
                )
            }
        }
    }

    /// Produces an async sequence of entities for the given UseCase keeping track of database changes.
    /// When the device is connected to the internet and there's no valid cache, it makes a request to the API and saves the response to the database. If there's valid cache, it returns it.
    /// By default it downloads all pages, and validates cache unless specificied differently.
    /// When the device is offline, it will read data from Core Data.

    /// - Parameters:
    ///     - ignoreCache: Indicates if the request should check the available cache first.
    ///       If it's set to **false**, it will validate the cache's expiration and return it if it's still valid. If the cache has expired it will make a request to the API.
    ///       If it's set to **true**, it will make a request to the API.
    ///       Defaults to **false**.
    ///     - loadAllPages: Tells the request if it should load all the pages or just the first one. Defaults to **true**.
    /// - Returns: An async sequence of list of entities.
    public func streamEntities(ignoreCache: Bool = false, loadAllPages: Bool = true) async throws -> AsyncThrowingStream<[U.Model], Error> {
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order

        return if offlineModeInteractor?.isOfflineModeEnabled() == true {
            Self.streamEntitiesFromDatabase(
                fetchRequest: request,
                context: context
            )
        } else {
            if ignoreCache {
                try await Self.streamEntitiesFromAPI(
                    useCase: useCase,
                    loadAllPages: loadAllPages,
                    fetchRequest: request,
                    context: context,
                    environment: environment
                    )
            } else {
                try await Self.streamEntitiesFromCache(
                    useCase: useCase,
                    fetchRequest: request,
                    loadAllPages: loadAllPages,
                    context: context,
                    environment: environment
                )
            }
        }
    }

    public func getEntitiesFromDatabase() async throws -> [U.Model] {
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order

        return try await Self.fetchEntitiesFromDatabase(fetchRequest: request, context: context)
    }

    /// - Warning: This stream **does not terminate**. Ensure proper cancellation of its consuming task.
    public func streamEntitiesFromDatabase() throws -> AsyncThrowingStream<[U.Model], Error> {
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order

        return Self.streamEntitiesFromDatabase(fetchRequest: request, context: context)
    }

    /// Refreshes the entities by requesting the latest data from the API.
    public func forceRefresh(loadAllPages: Bool = true) async {
        _ = try? await getEntities(ignoreCache: true, loadAllPages: loadAllPages)
    }

    private static func fetchEntitiesFromCache<T: NSManagedObject>(
        useCase: U,
        fetchRequest: NSFetchRequest<T>,
        loadAllPages: Bool,
        context: NSManagedObjectContext,
        environment: AppEnvironment
    ) async throws -> [T] {
        let hasExpired = await useCase.hasCacheExpired(environment: environment)

        return if hasExpired {
            try await Self.fetchEntitiesFromAPI(
                useCase: useCase,
                loadAllPages: loadAllPages,
                fetchRequest: fetchRequest,
                context: context,
                environment: environment
            )
        } else {
            try await Self.fetchEntitiesFromDatabase(fetchRequest: fetchRequest, context: context)
        }
    }

    private static func streamEntitiesFromCache<T: NSManagedObject>(
        useCase: U,
        fetchRequest: NSFetchRequest<T>,
        loadAllPages: Bool,
        context: NSManagedObjectContext,
        environment: AppEnvironment
    ) async throws -> AsyncThrowingStream<[T], Error> {
        let hasExpired = await useCase.hasCacheExpired(environment: environment)

        return if hasExpired {
            try await Self.streamEntitiesFromAPI(
                useCase: useCase,
                loadAllPages: loadAllPages,
                fetchRequest: fetchRequest,
                context: context,
                environment: environment
            )
        } else {
            Self.streamEntitiesFromDatabase(fetchRequest: fetchRequest, context: context)
        }
    }

    private static func fetchEntitiesFromAPI<T: NSManagedObject>(
        useCase: U,
        getNextUseCase: GetNextUseCase<U>? = nil,
        loadAllPages: Bool,
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext,
        environment: AppEnvironment
    ) async throws -> [T] {
        let urlResponse = if let getNextUseCase {
            try await getNextUseCase.fetch(environment: environment)
        } else {
            try await useCase.fetch(environment: environment)
        }

        let nextResponse = urlResponse.flatMap { useCase.getNext(from: $0) }
        try await Self.fetchAllPagesIfNeeded(
            useCase: useCase,
            loadAllPages: loadAllPages,
            nextResponse: nextResponse,
            fetchRequest: fetchRequest,
            context: context,
            environment: environment
        )

        return try await Self.fetchEntitiesFromDatabase(fetchRequest: fetchRequest, context: context)
    }

    private static func streamEntitiesFromAPI<T: NSManagedObject>(
        useCase: U,
        getNextUseCase: GetNextUseCase<U>? = nil,
        loadAllPages: Bool,
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext,
        environment: AppEnvironment
    ) async throws -> AsyncThrowingStream<[T], Error> {
        let urlResponse = if let getNextUseCase {
            try await getNextUseCase.fetch(environment: environment)
        } else {
            try await useCase.fetch(environment: environment)
        }

        let nextResponse = urlResponse.flatMap { useCase.getNext(from: $0) }
        try await Self.fetchAllPagesIfNeeded(
            useCase: useCase,
            loadAllPages: loadAllPages,
            nextResponse: nextResponse,
            fetchRequest: fetchRequest,
            context: context,
            environment: environment
        )

        return Self.streamEntitiesFromDatabase(fetchRequest: fetchRequest, context: context)
    }

    private static func fetchAllPagesIfNeeded<T: NSManagedObject>(
        useCase: U,
        loadAllPages: Bool,
        nextResponse: GetNextRequest<U.Response>?,
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext,
        environment: AppEnvironment
    ) async throws {
        guard loadAllPages else { return }
        let nextPageUseCase = getNextPage(useCase: useCase, nextResponse: nextResponse)

        if let nextPageUseCase {
            _ = try await Self.fetchEntitiesFromAPI(
                useCase: useCase,
                getNextUseCase: nextPageUseCase,
                loadAllPages: true,
                fetchRequest: fetchRequest,
                context: context,
                environment: environment
            )
        }
    }

    private static func getNextPage(
        useCase: U,
        nextResponse: GetNextRequest<U.Response>?
    ) -> GetNextUseCase<U>? {
        if let nextResponse {
            GetNextUseCase(parent: useCase, request: nextResponse)
        } else {
            nil
        }
    }

    private static func fetchEntitiesFromDatabase<T: NSManagedObject>(
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext
    ) async throws -> [T] {
        try await FetchedResultsPublisher(request: fetchRequest, context: context)
            .asyncValue()
    }

    private static func streamEntitiesFromDatabase<T: NSManagedObject>(
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext
    ) -> AsyncThrowingStream<[T], Error> {
        FetchedResultsPublisher(request: fetchRequest, context: context)
            .asyncStream()
    }
}
