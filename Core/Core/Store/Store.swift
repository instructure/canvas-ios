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

public class Store<U>: NSObject, FetchedResultsControllerDelegate where U: UseCase {
    public typealias EventHandler = () -> Void

    public let env: AppEnvironment
    private let frc: FetchedResultsController<U.Model>
    public let useCase: U
    public let eventHandler: EventHandler

    public var count: Int {
        return numberOfObjects(inSection: 0)
    }

    public var numberOfSections: Int {
        return frc.sections?.count ?? 0
    }

    public var first: U.Model? {
        return frc.fetchedObjects?.first
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
        let frc: FetchedResultsController<U.Model> = env.database.fetchedResultsController(
            predicate: scope.predicate,
            sortDescriptors: scope.order,
            sectionNameKeyPath: scope.sectionNameKeyPath
        )
        self.frc = frc
        self.eventHandler = eventHandler

        super.init()

        frc.delegate = self
        frc.performFetch()
    }

    private func notify() {
        DispatchQueue.main.async {
            self.eventHandler()
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

    public func refresh(force: Bool = false) {
        notify() // send cache
        pending = true
        env.fetch(useCase, force: force) { [weak self] _, urlResponse, error in
            self?.pending = false
            if let error = error {
                self?.error = error
            }
            if let urlResponse = urlResponse {
                self?.next = self?.useCase.getNext(from: urlResponse)
            }
        }
    }

    public func getNextPage() {
        guard let next = next else {
            return
        }
        let useCase = GetNextUseCase(parent: self.useCase, request: next)
        env.fetch(useCase, force: true) { [weak self] _, urlResponse, error in
            if let error = error {
                self?.error = error
            }
            if let urlResponse = urlResponse {
                self?.next = self?.useCase.getNext(from: urlResponse)
            }
        }
    }

    public func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        notify()
    }
}
