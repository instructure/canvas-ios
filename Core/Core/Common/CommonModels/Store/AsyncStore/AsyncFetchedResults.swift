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

@preconcurrency import CoreData

public struct AsyncFetchedResults<Model: NSManagedObject> {
    private let request: NSFetchRequest<Model>
    private let context: NSManagedObjectContext

    public init(request: NSFetchRequest<Model>, context: NSManagedObjectContext) {
        self.request = request
        self.context = context
    }

    public func fetch<Result: Sendable>(convert: @escaping (Model) -> Result) async throws -> [Result] {
        try await context.fetch(request, convert: convert)
    }

    public func stream<Result: Sendable>(convert: @escaping (Model) -> Result) -> AsyncThrowingStream<[Result], Error> {
        AsyncThrowingStream { continuation in
            let observer = FetchedResultsObserver(
                request: request,
                context: context,
                continuation: continuation,
                convert: convert
            )

            continuation.onTermination = { _ in
                observer.cancel()
            }
        }
    }
}

private final class FetchedResultsObserver<Model: NSManagedObject, Result: Sendable>: NSObject, NSFetchedResultsControllerDelegate {
    private var controller: NSFetchedResultsController<Model>?
    private let continuation: AsyncThrowingStream<[Result], Error>.Continuation
    private let context: NSManagedObjectContext
    private let convert: (Model) -> Result

    init(
        request: NSFetchRequest<Model>,
        context: NSManagedObjectContext,
        continuation: AsyncThrowingStream<[Result], Error>.Continuation,
        convert: @escaping (Model) -> Result
    ) {
        self.continuation = continuation
        self.context = context
        self.convert = convert
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
            self.continuation.yield(entities.map(self.convert))
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
    public func fetch<Result: Sendable, Model: NSManagedObject>(
        _ request: NSFetchRequest<Model>,
        convert: @escaping (Model) -> Result
    ) async throws -> [Result] {
        try await perform {
            try self.fetch(request).map(convert)
        }
    }
}
