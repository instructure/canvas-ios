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
    public enum State: Equatable {
        public static func == (lhs: ReactiveStore<U>.State, rhs: ReactiveStore<U>.State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading): return true
            case let (.error(lError), .error(rError)):
                guard type(of: lhs) == type(of: rhs) else { return false }
                let error1 = lError as NSError
                let error2 = rError as NSError
                return error1.domain == error2.domain && error1.code == error2.code
            case let (.data(lData), .data(rData)): return lData == rData
            default: return false
            }
        }

        case loading, error(Error), data([U.Model])
    }

    private let env: AppEnvironment
    private let offlineService: OfflineService
    private let useCase: U
    private let context: NSManagedObjectContext

    private var next: GetNextRequest<U.Response>?

    private let forceRefreshRelay = PassthroughRelay<Void>()
    private let stateRelay = CurrentValueRelay<State>(.loading)

    private var cancellable: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: -

    public init(
        env: AppEnvironment = .shared,
        offlineService: OfflineService = OfflineServiceLive(),
        context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext,
        useCase: U
    ) {
        self.env = env
        self.offlineService = offlineService
        self.useCase = useCase
        self.context = context

        unowned let unownedSelf = self

        forceRefreshRelay
            .flatMap { _ in unownedSelf.observeEntities(forceFetch: true) }
            .sink()
            .store(in: &subscriptions)
    }

    public func forceFetchEntities() -> AnyPublisher<Void, Never> {
        forceRefreshRelay.accept(())
        return Empty(completeImmediately: false)
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
    }

    public func observeEntities(forceFetch: Bool = false, loadAllPages: Bool = false) -> AnyPublisher<State, Never> {
        cancellable?.cancel()
        cancellable = nil

        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order

        let entitiesPublisher: AnyPublisher<[U.Model], Error>

        if offlineService.isOfflineModeEnabled() {
            entitiesPublisher = fetchEntitiesFromDatabase(fetchRequest: request)
        } else {
            entitiesPublisher = forceFetch ?
                fetchEntitiesFromAPI(useCase: useCase, loadAllPages: loadAllPages, fetchRequest: request) :
                fetchEntitiesFromCache(fetchRequest: request)
        }

        cancellable = entitiesPublisher
            .handleEvents(receiveSubscription: { _ in
                self.stateRelay.accept(.loading)
            })
            .catch {
                self.stateRelay.accept(.error($0))
                return Empty<[U.Model], Never>(completeImmediately: false)
                    .setFailureType(to: Never.self)
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveValue: { value in
                    self.stateRelay.accept(.data(value))
                }
            )

        return stateRelay.eraseToAnyPublisher()
    }

    public func getEntities() -> AnyPublisher<[U.Model], Error> {
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order

        if offlineService.isOfflineModeEnabled() {
            return fetchEntitiesFromDatabase(fetchRequest: request)
                .first()
                .eraseToAnyPublisher()
        } else {
            return fetchEntitiesFromAPI(useCase: useCase, loadAllPages: false, fetchRequest: request)
                .first()
                .eraseToAnyPublisher()
        }
    }

    private func fetchEntitiesFromCache<T: NSManagedObject>(
        fetchRequest: NSFetchRequest<T>
    ) -> AnyPublisher<[T], Error> {
        unowned let unownedSelf = self

        return useCase.hasCacheExpired()
            .setFailureType(to: Error.self)
            .flatMap { hasExpired -> AnyPublisher<[T], Error> in
                if hasExpired {
                    return unownedSelf.fetchEntitiesFromAPI(
                        useCase: unownedSelf.useCase,
                        loadAllPages: false,
                        fetchRequest: fetchRequest
                    )
                } else {
                    return unownedSelf.fetchEntitiesFromDatabase(fetchRequest: fetchRequest)
                }
            }
            .eraseToAnyPublisher()
    }

    private func fetchEntitiesFromAPI<T: NSManagedObject>(
        useCase: any UseCase,
        loadAllPages: Bool,
        fetchRequest: NSFetchRequest<T>
    ) -> AnyPublisher<[T], Error> {
        unowned let unownedSelf = self

        return useCase.fetchWithFuture()
            .handleEvents(receiveOutput: { [weak self] urlResponse in
                if let urlResponse {
                    self?.next = self?.useCase.getNext(from: urlResponse)
                } else {
                    self?.next = nil
                }
            })
            .flatMap { _ in unownedSelf.fetchAllPagesIfNeeded(loadAllPages, fetchRequest: fetchRequest) }
            .flatMap { _ in unownedSelf.fetchEntitiesFromDatabase(fetchRequest: fetchRequest) }
            .eraseToAnyPublisher()
    }

    private func fetchAllPagesIfNeeded<T: NSManagedObject>(
        _ loadAllPages: Bool,
        fetchRequest: NSFetchRequest<T>
    ) -> AnyPublisher<Void, Error> {
        unowned let unownedSelf = self

        let voidPublisher: () -> AnyPublisher<Void, Error> = {
            Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard loadAllPages else {
            return voidPublisher()
        }

        return getNextPage()
            .setFailureType(to: Error.self)
            .flatMap { nextPageUseCase -> AnyPublisher<Void, Error> in
                if let nextPageUseCase {
                    return unownedSelf.fetchEntitiesFromAPI(
                        useCase: nextPageUseCase,
                        loadAllPages: true,
                        fetchRequest: fetchRequest
                    )
                    .map { _ in () }
                    .eraseToAnyPublisher()
                } else {
                    return voidPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func getNextPage() -> AnyPublisher<GetNextUseCase<U>?, Never> {
        if let next {
            return Just(
                GetNextUseCase(
                    parent: useCase,
                    request: next
                )
            ).eraseToAnyPublisher()
        } else {
            next = nil
            return Just(nil).eraseToAnyPublisher()
        }
    }

    private func fetchEntitiesFromDatabase<T: NSManagedObject>(
        fetchRequest: NSFetchRequest<T>,
        sectionNameKeyPath: String? = nil,
        cacheName: String? = nil
    ) -> AnyPublisher<[T], Error> {
        unowned let unownedSelf = self

        return AnyPublisher<[T], Error>.create { subscriber in

            let observer = FetchedResultsPublisher(
                subscriber: subscriber,
                fetchRequest: fetchRequest,
                managedObjectContext: unownedSelf.context,
                sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName
            )

            return AnyCancellable {
                observer.cancel()
            }
        }
    }
}
