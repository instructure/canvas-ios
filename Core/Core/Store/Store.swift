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

import Foundation
import CoreData
import Combine
import SwiftUI

public enum StoreState { case data, empty, error, loading }

public enum StoreChange: Equatable {
    case insertSection(Int)
    case deleteSection(Int)
    case insertRow(IndexPath)
    case updateRow(IndexPath)
    case deleteRow(IndexPath)
}

public class Store<U: UseCase>: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    public typealias EventHandler = () -> Void

    public let env: AppEnvironment
    public private(set) var changes = [StoreChange]()
    public let useCase: U
    public var eventHandler: EventHandler

    public var numberOfSections: Int { frc.sections?.count ?? 0 }
    public var sections: [NSFetchedResultsSectionInfo]? { frc.sections }

    public var count: Int { frc.sections?.first?.numberOfObjects ?? 0 }
    public var all: [U.Model] { frc.fetchedObjects ?? [] }
    public var first: U.Model? { frc.fetchedObjects?.first }
    public var last: U.Model? { frc.fetchedObjects?.last }
    public var isEmpty: Bool { count == 0 }
    public var hasNextPage: Bool { next != nil }

    public var state: StoreState {
        error != nil ? .error :
        !isEmpty ? .data :
        !requested || pending ? .loading :
        .empty
    }

    /**
     `true` if the `refresh(force: false)` method will return data from the permanent store without any API calls.

     Use this to decide if a loading screen should be shown or not. Objects from the permanent store are available very quickly
     so no loading indicator is necessary, on the other hand if the store will fetch data from the API it could be a lenghty operation.
     */
    public var isCachedDataAvailable: Bool { !isCachedDataExpired }
    /**
     The opposite of `isCachedDataAvailable`.
     */
    public var isCachedDataExpired: Bool { useCase.hasExpired(in: frc.managedObjectContext) }

    public private(set) var pending: Bool = false
    public private(set) var requested: Bool = false
    public private(set) var error: Error?

    private var next: GetNextRequest<U.Response>? {
        didSet {
            hasNextPageSubject.send(next != nil)
        }
    }
    private let frc: NSFetchedResultsController<U.Model>

    // MARK: - ObservableObject

    // The default implementation of objectWillChange requires at least one
    // @Published property, since we have none we create this publisher manually
    public var objectWillChange = ObservableObjectPublisher()

    private func willChange() {
        performUIUpdate { withAnimation {
            self.objectWillChange.send()
        } }
    }

    // MARK: - Reactive Property Extensions

    /**
     Publisher for all objects in this store. Changes are sent on the main thread with CoreData objects from the view context.
     */
    public private(set) lazy var allObjects: AnyPublisher<[U.Model], Never> = allObjectsSubject
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    /**
     Returns `.loading` until `refresh()` is called. After refresh completes the published state can be either `.data`, `.empty` or `.error`.
     */
    public private(set) lazy var statePublisher: AnyPublisher<StoreState, Never> = stateSubject
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    public private(set) lazy var hasNextPagePublisher: AnyPublisher<Bool, Never> = hasNextPageSubject
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    private let allObjectsSubject = CurrentValueSubject<[U.Model], Never>([])
    private let stateSubject = CurrentValueSubject<StoreState, Never>(.loading)
    private let hasNextPageSubject = CurrentValueSubject<Bool, Never>(false)
    private let offlineModeInteractor: OfflineModeInteractor

    // MARK: -

    public init(
        env: AppEnvironment,
        offlineModeInteractor: OfflineModeInteractor = OfflineModeInteractorLive.shared,
        context: NSManagedObjectContext,
        useCase: U,
        eventHandler: @escaping EventHandler
    ) {
        self.env = env
        self.offlineModeInteractor = offlineModeInteractor
        self.useCase = useCase
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order
        let frc = NSFetchedResultsController<U.Model>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: scope.sectionNameKeyPath,
            cacheName: nil
        )
        self.frc = frc
        self.eventHandler = eventHandler

        super.init()

        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            assertionFailure("Failed to performFetch \(error)")
        }
        allObjectsSubject.send(all)
    }

    public convenience init(env: AppEnvironment, database: NSPersistentContainer? = nil, useCase: U, eventHandler: @escaping EventHandler) {
        self.init(env: env, context: (database ?? env.database).viewContext, useCase: useCase, eventHandler: eventHandler)
    }

    /// Updates predicate & sortDescriptors, but not sectionNameKeyPath.
    public func setScope(_ scope: Scope) {
        frc.fetchRequest.predicate = scope.predicate
        frc.fetchRequest.sortDescriptors = scope.order
        do {
            try frc.performFetch()
        } catch {
            assertionFailure("Failed to performFetch \(error)")
        }
        allObjectsSubject.send(all)
    }

    public subscript(indexPath: IndexPath) -> U.Model? {
        guard let sections = frc.sections, sections.count > indexPath.section, sections[indexPath.section].numberOfObjects > indexPath.row else {
            return nil
        }

        let object = frc.object(at: indexPath)
        if frc.managedObjectContext.isObjectDeleted(object) {
            return nil
        }
        return object
    }

    public subscript(index: Int) -> U.Model? {
        return self[IndexPath(row: index, section: 0)]
    }

    public func numberOfObjects(inSection section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    public func sectionInfo(inSection section: Int) -> NSFetchedResultsSectionInfo? {
        return frc.sections?[section]
    }

    @discardableResult
    public func refresh(force: Bool = false,
                        callback: ((U.Response?) -> Void)? = nil)
    -> Self {
        request(useCase, force: force, callback: callback)
        return self
    }

    public func forceFetchObjects() throws {
        try frc.performFetch()
        notify()
        allObjectsSubject.send(all)
    }

    @discardableResult
    public func exhaust(force: Bool = true,
                        while condition: @escaping (U.Response?) -> Bool = { _ in true }
    ) -> Self {
        refresh(force: force) { [weak self] response in
            if let response = response, condition(response) {
                self?.exhaustNext(while: condition)
            } else {
                _ = condition(nil)
            }
        }
    }

    public func getNextPage(_ callback: ((U.Response?) -> Void)? = nil) {
        guard let next = next else {
            performUIUpdate {
                callback?(nil)
            }
            return
        }
        self.next = nil
        let useCase = GetNextUseCase(parent: self.useCase, request: next)
        request(useCase, force: true, callback: callback)
    }

    /**
     Dismisses the stored UseCase of the next page.
     */
    public func resetNextPage() {
        next = nil
    }

    // MARK: - Reactive Functions

    public func refreshWithFuture(force: Bool = false) -> Future<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            self.request(self.useCase, force: force) { _ in
                promise(.success(()))
            }
        }
    }

    public func exhaustWithFuture(
        force: Bool = true,
        while condition: @escaping (U.Response) -> Bool = { _ in true }
    ) -> Future<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            self.refresh(force: force) { [weak self] response in
                if let response = response, condition(response) {
                    self?.exhaustNext(while: condition) {
                        promise(.success(()))
                    }
                }
            }
        }
    }

    // MARK: - Private Methods

    private func notify() {
        performUIUpdate {
            self.eventHandler()
            self.changes = []
        }
    }

    private func exhaustNext(while condition: @escaping (U.Response) -> Bool, completion: (() -> Void)? = nil) {
        getNextPage { [weak self] response in
            if let response = response, condition(response) {
                self?.exhaustNext(while: condition, completion: completion)
            } else {
                completion?()
            }
        }
    }

    private func request<UC: UseCase>(_ useCase: UC, force: Bool, callback: ((UC.Response?) -> Void)? = nil) {
        willChange()
        requested = true
        pending = true
        notify()

        if offlineModeInteractor.isOfflineModeEnabled() {
            pending = false
            error = nil
            publishState()
            notify()
            performUIUpdate {
                callback?(nil)
            }
        } else {
            useCase.fetch(environment: env, force: force) { [weak self] response, urlResponse, error in
                self?.willChange()
                self?.error = error
                self?.pending = false
                if let urlResponse = urlResponse {
                    self?.next = self?.useCase.getNext(from: urlResponse)
                }
                self?.notify()
                self?.publishState()
                performUIUpdate {
                    callback?(response)
                }
            }
        }
    }

    private func publishState() {
        guard requested, !pending else { return }
        var state: StoreState = .data

        if error != nil {
            state = .error
        } else if isEmpty {
            state = .empty
        }

        stateSubject.send(state)
    }

    // MARK: - NSFetchedResultsControllerDelegate

    @objc
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        willChange()
    }

    @objc
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        changes.append(type == .delete ? .deleteSection(sectionIndex) : .insertSection(sectionIndex))
    }

    @objc
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        if type == .insert, let index = newIndexPath {
            changes.append(.insertRow(index))
        } else if type == .delete, let index = indexPath {
            changes.append(.deleteRow(index))
        } else if type == .update, let index = indexPath {
            changes.append(.updateRow(index))
        } else if type == .move, let old = indexPath, let index = newIndexPath {
            changes.append(.deleteRow(old))
            changes.append(.insertRow(index))
        }
    }

    @objc
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notify()
        allObjectsSubject.send(all)
        publishState()
    }

    // MARK: -
}

public struct FetchedResultsControllerGenerator<T: NSManagedObject>: IteratorProtocol {
    public typealias Element = T

    var index: Int = 0
    let fetchedResultsController: NSFetchedResultsController<T>

    init(fetchedResultsController: NSFetchedResultsController<T>) {
        self.fetchedResultsController = fetchedResultsController
    }

    public mutating func next() -> T? {
        guard let count = fetchedResultsController.fetchedObjects?.count else { return nil }
        guard index < count else { return nil }
        defer { index += 1 }
        return fetchedResultsController.fetchedObjects?[index]
    }
}

extension Store: Sequence {
    public func makeIterator() -> FetchedResultsControllerGenerator<U.Model> {
        return FetchedResultsControllerGenerator<U.Model>(fetchedResultsController: frc)
    }
}
