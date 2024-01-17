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
import CombineExt
import CoreData
import Foundation

public class ReactiveStore<U: UseCase> {
    private let offlineModeInteractor: OfflineModeInteractor?
    private let useCase: U
    private let context: NSManagedObjectContext

    // MARK: - Init

    public init(
        offlineModeInteractor: OfflineModeInteractor? = OfflineModeAssembly.make(),
        context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext,
        useCase: U
    ) {
        self.offlineModeInteractor = offlineModeInteractor
        self.useCase = useCase
        self.context = context
    }

    /// Produces a list of entities for the given UseCase.
    /// When the device is connected to the internet, it will fetch data from the API by downloading all pages, unless specificied differently. The result is then cached to the database
    /// emitted by the publisher.
    /// When the device is offline, it will read data from Core Data.
    /// - Parameters:
    ///     - forceFetch: Tells the fetch request if it should get data from the API or from cache. Defaults to **false**.
    ///     - loadAllPages: Tells the fetch request if it should load all the pages or just the first one. Defaults to **true**.
    ///     - publishDatabaseChanges: Tells the fetch request to keep observing database changes after the API response is downloaded and saved. Defaults to **false**.
    ///
    /// - Returns: A list of entities or an error.
    public func getEntities(
        forceFetch: Bool = false,
        loadAllPages: Bool = true,
        publishDatabaseChanges: Bool = false
    ) -> AnyPublisher<[U.Model], Error> {
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order

        var entitiesPublisher: AnyPublisher<[U.Model], Error>

        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            entitiesPublisher = Self.fetchEntitiesFromDatabase(
                fetchRequest: request,
                context: context
            )
        } else {
            entitiesPublisher = forceFetch ?
                Self.fetchEntitiesFromAPI(
                    useCase: useCase,
                    loadAllPages: loadAllPages,
                    fetchRequest: request,
                    context: context
                ) :
                Self.fetchEntitiesFromCache(
                    useCase: useCase,
                    fetchRequest: request,
                    context: context
                )
        }

        if !publishDatabaseChanges {
            entitiesPublisher = entitiesPublisher.first().eraseToAnyPublisher()
        }

        return entitiesPublisher
    }

    public func getEntitiesFromDatabase() -> AnyPublisher<[U.Model], Error> {
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order

        return Self.fetchEntitiesFromDatabase(fetchRequest: request, context: context)
            .first()
            .eraseToAnyPublisher()
    }

    public func forceRefresh(loadAllPages: Bool = true) -> AnyPublisher<Void, Never> {
        getEntities(
            forceFetch: true,
            loadAllPages: loadAllPages,
            publishDatabaseChanges: false
        )
        .replaceError(with: [])
        .setFailureType(to: Never.self)
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private static func fetchEntitiesFromCache<T: NSManagedObject>(
        useCase: U,
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext
    ) -> AnyPublisher<[T], Error> {
        return useCase.hasCacheExpired()
            .setFailureType(to: Error.self)
            .flatMap { hasExpired -> AnyPublisher<[T], Error> in
                if hasExpired {
                    return Self.fetchEntitiesFromAPI(
                        useCase: useCase,
                        loadAllPages: false,
                        fetchRequest: fetchRequest,
                        context: context
                    )
                } else {
                    return Self.fetchEntitiesFromDatabase(fetchRequest: fetchRequest, context: context)
                }
            }
            .eraseToAnyPublisher()
    }

    private static func fetchEntitiesFromAPI<T: NSManagedObject>(
        useCase: U,
        getNextUseCase: GetNextUseCase<U>? = nil,
        loadAllPages: Bool,
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext
    ) -> AnyPublisher<[T], Error> {
        let useCaseToFetch: Future<URLResponse?, Error>

        if let getNextUseCase {
            useCaseToFetch = getNextUseCase.fetchWithFuture()
        } else {
            useCaseToFetch = useCase.fetchWithFuture()
        }

        return useCaseToFetch
            .map {
                if let urlResponse = $0 {
                    return useCase.getNext(from: urlResponse)
                } else {
                    return nil
                }
            }
            .flatMap {
                Self.fetchAllPagesIfNeeded(
                    useCase: useCase,
                    loadAllPages: loadAllPages,
                    nextResponse: $0,
                    fetchRequest: fetchRequest,
                    context: context
                )
            }
            .flatMap { _ in Self.fetchEntitiesFromDatabase(fetchRequest: fetchRequest, context: context) }
            .eraseToAnyPublisher()
    }

    private static func fetchAllPagesIfNeeded<T: NSManagedObject>(
        useCase: U,
        loadAllPages: Bool,
        nextResponse: GetNextRequest<U.Response>?,
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext
    ) -> AnyPublisher<Void, Error> {
        let voidPublisher: () -> AnyPublisher<Void, Error> = {
            Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard loadAllPages else {
            return voidPublisher()
        }

        return getNextPage(useCase: useCase, nextResponse: nextResponse)
            .setFailureType(to: Error.self)
            .flatMap { nextPageUseCase -> AnyPublisher<Void, Error> in
                if let nextPageUseCase {
                    return Self.fetchEntitiesFromAPI(
                        useCase: useCase,
                        getNextUseCase: nextPageUseCase,
                        loadAllPages: true,
                        fetchRequest: fetchRequest,
                        context: context
                    )
                    .map { _ in () }
                    .eraseToAnyPublisher()
                } else {
                    return voidPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private static func getNextPage(
        useCase: U,
        nextResponse: GetNextRequest<U.Response>?
    ) -> AnyPublisher<GetNextUseCase<U>?, Never> {
        if let nextResponse {
            return Just(
                GetNextUseCase(
                    parent: useCase,
                    request: nextResponse
                )
            ).eraseToAnyPublisher()
        } else {
            return Just(nil).eraseToAnyPublisher()
        }
    }

    private static func fetchEntitiesFromDatabase<T: NSManagedObject>(
        fetchRequest: NSFetchRequest<T>,
        sectionNameKeyPath _: String? = nil,
        cacheName _: String? = nil,
        context: NSManagedObjectContext
    ) -> AnyPublisher<[T], Error> {
        FetchedResultsPublisher(
            request: fetchRequest,
            context: context
        )
        .eraseToAnyPublisher()
    }
}
