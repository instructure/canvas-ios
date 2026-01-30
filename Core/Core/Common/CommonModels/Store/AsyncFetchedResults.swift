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
@preconcurrency import CoreData

public final class AsyncFetchedResults<ResultType: NSFetchRequestResult> {
    private let request: NSFetchRequest<ResultType>
    private let context: NSManagedObjectContext

    public init(
        request: NSFetchRequest<ResultType>,
        context: NSManagedObjectContext
    ) {
        self.request = request
        self.context = context
    }

    public func fetch() async throws -> [ResultType] {
        try await context.fetch(request)
    }

    public func stream() -> AsyncThrowingStream<[ResultType], Error> {
        AsyncThrowingStream { continuation in
            let observer = FetchedResultsObserver(
                request: request,
                context: context,
                continuation: continuation
            )

            continuation.onTermination = { _ in
                observer.cancel()
            }
        }
    }
}

private final class FetchedResultsObserver<ResultType: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    private var controller: NSFetchedResultsController<ResultType>?
    private let continuation: AsyncThrowingStream<[ResultType], Error>.Continuation
    private let context: NSManagedObjectContext

    init(
        request: NSFetchRequest<ResultType>,
        context: NSManagedObjectContext,
        continuation: AsyncThrowingStream<[ResultType], Error>.Continuation
    ) {
        self.continuation = continuation
        self.context = context
        super.init()

        context.perform { [weak self] in
            guard let self else { return }

            self.controller = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            self.controller?.delegate = self

            do {
                try self.controller?.performFetch()
                self.sendElement()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    private func sendElement() {
        context.perform { [weak self] in
            guard let self else { return }
            let entities = self.controller?.fetchedObjects ?? []
            self.continuation.yield(entities)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendElement()
    }

    func cancel() {
        context.perform { [weak self] in
            self?.controller?.delegate = nil
            self?.controller = nil
            self?.continuation.finish()
        }
    }
}

extension NSManagedObjectContext {
    public func fetch<R: NSFetchRequestResult>(_ request: NSFetchRequest<R>) async throws -> [R] {
        try await perform {
            try self.fetch(request)
        }
    }
}
