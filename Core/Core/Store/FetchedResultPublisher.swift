//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public final class FetchedResultsPublisher<ResultType>: Publisher where ResultType: NSFetchRequestResult {
    public init(
        request: NSFetchRequest<ResultType>,
        context: NSManagedObjectContext
    ) {
        self.request = request
        self.context = context
    }

    let request: NSFetchRequest<ResultType>
    let context: NSManagedObjectContext

    // MARK: - Publisher

    public typealias Output = [ResultType]
    public typealias Failure = Error

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        subscriber.receive(subscription: FetchedResultsSubscription(
            subscriber: subscriber,
            request: request,
            context: context
        ))
    }
}

final class FetchedResultsSubscription
<SubscriberType, ResultType>:
    NSObject, Subscription, NSFetchedResultsControllerDelegate
    where
    SubscriberType: Subscriber,
    SubscriberType.Input == [ResultType],
    SubscriberType.Failure == Error,
    ResultType: NSFetchRequestResult {
    init(
        subscriber: SubscriberType,
        request: NSFetchRequest<ResultType>,
        context: NSManagedObjectContext
    ) {
        self.subscriber = subscriber
        self.request = request
        self.context = context
    }

    private(set) var subscriber: SubscriberType?
    private(set) var request: NSFetchRequest<ResultType>?
    private(set) var context: NSManagedObjectContext?
    private(set) var controller: NSFetchedResultsController<ResultType>?

    // MARK: - Subscription

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0,
              let subscriber = subscriber,
              let request = request,
              let context = context else { return }

        controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller?.delegate = self

        context.perform { [weak self] in
            guard let self = self else { return }
            self.controller?.delegate = self

            do {
                try self.controller?.performFetch()
            } catch {
                subscriber.receive(completion: .failure(NSError.instructureError("Error while reading from Core Data")))
            }

            self.sendElement()
        }
    }

    private func sendElement() {
        controller?.managedObjectContext.perform { [weak self] in
            guard let self = self, let subscriber = self.subscriber else { return }
            let entities = self.controller?.fetchedObjects ?? []
            _ = subscriber.receive(entities)
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(
        _: NSFetchedResultsController<NSFetchRequestResult>) {
        sendElement()
    }

    // MARK: - Cancellable

    func cancel() {
        subscriber = nil
        controller = nil
        request = nil
        context = nil
    }
}
