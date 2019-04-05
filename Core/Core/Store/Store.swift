//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

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
    public let eventHandler: EventHandler

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

    public var sections: [NSFetchedResultsSectionInfo]? {
        return frc.sections
    }

    public var isEmpty: Bool {
        return count == 0
    }

    private var next: GetNextRequest<U.Response>?

    public private(set) var pending: Bool = false {
        didSet {
            notify()
        }
    }

    public private(set) var error: Error? = nil {
        didSet {
            notify()
        }
    }

    init(env: AppEnvironment, useCase: U, eventHandler: @escaping EventHandler) {
        self.env = env
        self.useCase = useCase
        let scope = useCase.scope
        let frc: NSFetchedResultsController<U.Model> = env.database.fetchedResultsController(predicate: scope.predicate, sortDescriptors: scope.order, sectionNameKeyPath: scope.sectionNameKeyPath)
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

    private func notify() {
        performUIUpdate {
            self.eventHandler()
            self.changes = []
        }
    }

    public subscript(indexPath: IndexPath) -> U.Model? {
        return frc.object(at: indexPath)
    }

    public subscript(index: Int) -> U.Model? {
        return frc.object(at: IndexPath(row: index, section: 0))
    }

    public func numberOfObjects(inSection section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    public func refresh(force: Bool = false, callback: ((U.Response?) -> Void)? = nil) {
        pending = true
        useCase.fetch(environment: env, force: force) { [weak self] response, urlResponse, error in
            self?.pending = false
            if let error = error {
                self?.error = error
            }
            if let urlResponse = urlResponse {
                self?.next = self?.useCase.getNext(from: urlResponse)
            }
            performUIUpdate {
                callback?(response)
            }
        }
    }

    public func exhaust(while condition: @escaping (U.Response) -> Bool) {
        refresh(force: true) { [weak self] response in
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
        print("get next")
        useCase.fetch(environment: env, force: true) { [weak self] response, urlResponse, error in
            if let error = error {
                self?.error = error
            }
            if let urlResponse = urlResponse {
                self?.next = self?.useCase.getNext(from: urlResponse)
            }
            performUIUpdate {
                callback?(response)
            }
        }
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
        guard let count = fetchedResultsController.fetchedObjects?.count else { return nil}
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
