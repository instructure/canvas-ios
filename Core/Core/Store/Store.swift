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

public class Store<U: UseCase>: NSObject, NSFetchedResultsControllerDelegate {
    public typealias EventHandler = () -> Void

    public let env: AppEnvironment
    private let frc: NSFetchedResultsController<U.Model>
    public var changes = [StoreChange]()
    public let useCase: U
    public var eventHandler: EventHandler

    public var count: Int {
        return frc.sections?.first?.numberOfObjects ?? 0
    }

    public var numberOfSections: Int {
        return frc.sections?.count ?? 0
    }

    public var first: U.Model? {
        return frc.fetchedObjects?.first
    }

    public var last: U.Model? {
        return frc.fetchedObjects?.last
    }

    public var all: [U.Model] {
        return frc.fetchedObjects ?? []
    }

    public var sections: [NSFetchedResultsSectionInfo]? {
        return frc.sections
    }

    public var isEmpty: Bool {
        return count == 0
    }

    public var hasNextPage: Bool { next != nil }

    private var next: GetNextRequest<U.Response>?

    public private(set) var pending: Bool = false
    public private(set) var requested: Bool = false
    public private(set) var error: Error?

    public var state: StoreState {
        error != nil ? .error :
        !isEmpty ? .data :
        !requested || pending ? .loading :
        .empty
    }

    // The default implementation of objectWillChange requires at least one
    // @Published property
    public var objectWillChange = ObservableObjectPublisher()
    private func willChange() {
        performUIUpdate { withAnimation {
            self.objectWillChange.send()
        } }
    }

    public init(env: AppEnvironment, context: NSManagedObjectContext, useCase: U, eventHandler: @escaping EventHandler) {
        self.env = env
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
    }

    private func notify() {
        performUIUpdate {
            self.eventHandler()
            self.changes = []
        }
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
    public func refresh(force: Bool = false, callback: ((U.Response?) -> Void)? = nil) -> Self {
        request(useCase, force: force, callback: callback)
        return self
    }

    public func forceFetchObjects() throws {
        try frc.performFetch()
        notify()
    }

    @discardableResult
    public func exhaust(force: Bool = true, while condition: @escaping (U.Response) -> Bool = { _ in true }) -> Self {
        refresh(force: force) { [weak self] response in
            if let response = response, condition(response) {
                self?.exhaustNext(while: condition)
            }
        }
    }

    private func exhaustNext(while condition: @escaping (U.Response) -> Bool) {
        getNextPage { [weak self] response in
            if let response = response, condition(response) {
                self?.exhaustNext(while: condition)
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

    private func request<UC: UseCase>(_ useCase: UC, force: Bool, callback: ((UC.Response?) -> Void)? = nil) {
        willChange()
        requested = true
        pending = true
        notify()
        useCase.fetch(environment: env, force: force) { [weak self] response, urlResponse, error in
            self?.willChange()
            self?.error = error
            self?.pending = false
            if let urlResponse = urlResponse {
                self?.next = self?.useCase.getNext(from: urlResponse)
            }
            self?.notify()
            performUIUpdate {
                callback?(response)
            }
        }
    }

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
    }
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

extension Store: ObservableObject {
}
