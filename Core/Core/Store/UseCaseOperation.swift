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

public class UseCaseOperation<U: UseCase>: Operation {
    public typealias EventHandler = () -> Void
    public let env: AppEnvironment
    private let frc: NSFetchedResultsController<U.Model>
    public let useCase: U
    public let eventHandler: EventHandler
    private var next: GetNextRequest<U.Response>?

    public private(set) var pending: Bool = false
    public private(set) var error: Error?

    override public var isAsynchronous: Bool {
        return true
    }

    override public var isExecuting: Bool {
      return _isExecuting
    }

    override public var isFinished: Bool {
      return _isFinished
    }

    private var _isExecuting = false {
      willSet { willChangeValue(forKey: "isExecuting") }
      didSet { didChangeValue(forKey: "isExecuting") }
    }

    private var _isFinished = false {
      willSet { willChangeValue(forKey: "isFinished") }
      didSet { didChangeValue(forKey: "isFinished") }
    }


    public init(env: AppEnvironment, database: NSPersistentContainer? = nil, useCase: U, eventHandler: @escaping EventHandler) {
        self.env = env
        self.useCase = useCase
        let database = database ?? env.database
        let scope = useCase.scope
        let request = NSFetchRequest<U.Model>(entityName: String(describing: U.Model.self))
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order
        let frc = NSFetchedResultsController<U.Model>(
            fetchRequest: request,
            managedObjectContext: database.viewContext,
            sectionNameKeyPath: scope.sectionNameKeyPath,
            cacheName: nil
        )
        self.frc = frc
        self.eventHandler = eventHandler

        do {
            try frc.performFetch()
        } catch {
            assertionFailure("Failed to performFetch \(error)")
        }
    }

    override public func start() {
        guard !isCancelled else { return }

        exhaust(while: { _ in true })
        _isExecuting = true
    }

    public func refresh(force: Bool = false, callback: ((U.Response?) -> Void)? = nil) {
        request(useCase, force: force, callback: callback)
    }

    public func exhaust(while condition: @escaping (U.Response) -> Bool) {
        refresh(force: true) { [weak self] response in
            if let response = response, condition(response) {
                self?.exhaustNext(while: condition)
            }
            else {
                self?._isFinished = true
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
            callback?(nil)
            return
        }
        self.next = nil
        let useCase = GetNextUseCase(parent: self.useCase, request: next)
        request(useCase, force: true, callback: callback)
    }

    private func request<UC: UseCase>(_ useCase: UC, force: Bool, callback: ((UC.Response?) -> Void)? = nil) {
        useCase.fetch(environment: env, force: force) { [weak self] response, urlResponse, error in
            self?.error = error
            self?.pending = false
            if let urlResponse = urlResponse {
                self?.next = self?.useCase.getNext(from: urlResponse)
            }
        }
    }
}
