//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import UIKit


import CoreData
import ReactiveSwift

extension User {
    public static func predicate(_ observeeID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", observeeID)
    }

    public static func collection(_ session: Session, observeeID: String) throws -> FetchedCollection<User> {
        let pred = predicate(observeeID)
        let context = try session.observeesManagedObjectContext()
        
        return try FetchedCollection<User>(frc: context.fetchedResults(pred, sortDescriptors: ["sortableName".ascending]))
    }

    public static func observeeSyncProducer(_ session: Session, observeeID: String) throws -> User.ModelPageSignalProducer {
        let context = try session.observeesManagedObjectContext()
        let remote = try User.getObserveeUser(session, observeeID: observeeID).map { [$0] }
        let pred = predicate(observeeID)
        return User.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
    }

    public static func refresher(_ session: Session, observeeID: String) throws -> Refresher {
        let sync = try User.observeeSyncProducer(session, observeeID: observeeID)
        
        let key = cacheKey(try session.observeesManagedObjectContext(), [observeeID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(_ session: Session, observeeID: String) throws -> ManagedObjectObserver<User> {
        let pred = predicate(observeeID)
        let context = try session.observeesManagedObjectContext()
        return try ManagedObjectObserver<User>(predicate: pred, inContext: context)
    }

    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel>(_ session: Session, observeeID: String, detailsFactory: @escaping (User)->[DVM]) throws -> TableViewDataSource where DVM: Equatable {
        let obs = try observer(session, observeeID: observeeID)
        let collection = FetchedDetailsCollection<User, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }

    open class DetailViewController: TableViewController {
        fileprivate (set) open var observer: ManagedObjectObserver<User>!

        open func prepare<DVM: TableViewCellViewModel>(_ observer: ManagedObjectObserver<User>, refresher: Refresher? = nil, detailsFactory: @escaping (User)->[DVM]) where DVM: Equatable {
            self.observer = observer
            let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: details)
        }
    }
}
