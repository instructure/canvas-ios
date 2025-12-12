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

public class AsyncReactiveStore<U: AsyncUseCase> {
    private let offlineModeInteractor: OfflineModeInteractor?
    internal let useCase: U
    private let context: NSManagedObjectContext
    private let environment: AppEnvironment

    public init(
        offlineModeInteractor: OfflineModeInteractor? = OfflineModeAssembly.make(),
        context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext,
        useCase: U,
        environment: AppEnvironment = .shared
    ) {
        self.offlineModeInteractor = offlineModeInteractor
        self.useCase = useCase
        self.context = context
        self.environment = environment
    }

    // TODO: AsyncSequence version
    public func getEntites(
        ignoreCache: Bool = false,
        loadAllPages: Bool = true
    ) async throws -> [U.Model] {
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

    private static func fetchEntitiesFromCache<T: NSManagedObject>(
        useCase: U,
        fetchRequest: NSFetchRequest<T>,
        loadAllPages: Bool,
        context: NSManagedObjectContext,
        environment: AppEnvironment
    ) async throws -> [T] {
        let hasExpired = try await useCase.hasCacheExpired(environment: environment)

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

    private static func fetchEntitiesFromAPI<T: NSManagedObject>(
        useCase: U,
        getNextUseCase: AsyncGetNextUseCase<U>? = nil,
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

        let nextResponse = useCase.getNext(from: urlResponse)
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
    ) -> AsyncGetNextUseCase<U>? {
        if let nextResponse {
            AsyncGetNextUseCase(parent: useCase, request: nextResponse)
        } else {
            nil
        }
    }

    // TODO: convert to use native async/await
    private static func fetchEntitiesFromDatabase<T: NSManagedObject>(
        fetchRequest: NSFetchRequest<T>,
        sectionNameKeyPath _: String? = nil,
        cacheName _: String? = nil,
        context: NSManagedObjectContext
    ) async throws -> [T] {
        try await FetchedResultsPublisher(
            request: fetchRequest,
            context: context
        )
        .asyncPublisher()
    }
}
