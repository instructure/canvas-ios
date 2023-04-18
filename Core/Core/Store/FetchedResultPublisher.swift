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

public final class FetchedResultsPublisher<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    typealias Subscriber = Publishers.Create<[T], Error>.Subscriber

    private let subscriber: Subscriber
    private let frc: NSFetchedResultsController<T>

    init(
        subscriber: Subscriber,
        fetchRequest: NSFetchRequest<T>,
        managedObjectContext context: NSManagedObjectContext,
        sectionNameKeyPath: String?,
        cacheName: String?
    ) {
        self.subscriber = subscriber

        frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: cacheName
        )
        super.init()

        context.perform {
            self.frc.delegate = self

            do {
                try self.frc.performFetch()
            } catch {
                subscriber.send(completion: .failure(NSError(domain: "Core-Data Read Error", code: 0)))
            }

            self.sendNextElement()
        }
    }

    private func sendNextElement() {
        frc.managedObjectContext.perform {
            let entities = self.frc.fetchedObjects ?? []
            self.subscriber.send(entities)
        }
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

    public func cancel() {
        frc.delegate = nil
    }
}
