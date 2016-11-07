//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import TooLegit
import SoPersistent
import CoreData
import ReactiveCocoa

extension User {
    public static func predicate(observeeID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", observeeID)
    }

    public static func collection(session: Session, observeeID: String) throws -> FetchedCollection<User> {
        let pred = predicate(observeeID)
        let frc = User.fetchedResults(pred, sortDescriptors: ["sortableName".ascending], sectionNameKeypath: nil, inContext: try session.observeesManagedObjectContext())

        return try FetchedCollection<User>(frc: frc)
    }

    public static func observeeSyncProducer(session: Session, observeeID: String) throws -> User.ModelPageSignalProducer {
        let context = try session.observeesManagedObjectContext()
        let remote = try User.getObserveeUser(session, observeeID: observeeID).map { [$0] }
        let pred = predicate(observeeID)
        return User.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
    }

    public static func refresher(session: Session, observeeID: String) throws -> Refresher {
        let sync = try User.observeeSyncProducer(session, observeeID: observeeID)
        
        let key = cacheKey(try session.observeesManagedObjectContext(), [observeeID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(session: Session, observeeID: String) throws -> ManagedObjectObserver<User> {
        let pred = predicate(observeeID)
        let context = try session.observeesManagedObjectContext()
        return try ManagedObjectObserver<User>(predicate: pred, inContext: context)
    }

    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel where DVM: Equatable>(session: Session, observeeID: String, detailsFactory: User->[DVM]) throws -> TableViewDataSource {
        let obs = try observer(session, observeeID: observeeID)
        let collection = FetchedDetailsCollection<User, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }

    public class DetailViewController: TableViewController {
        private (set) public var observer: ManagedObjectObserver<User>!

        public func prepare<DVM: TableViewCellViewModel where DVM: Equatable>(observer: ManagedObjectObserver<User>, refresher: Refresher? = nil, detailsFactory: User->[DVM]) {
            self.observer = observer
            let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: details)
        }
    }
}