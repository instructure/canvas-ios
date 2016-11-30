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


extension Assignment {
    
    public static func detailsCacheKey(context: NSManagedObjectContext, courseID: String, id: String) -> String {
        return cacheKey(context, [courseID, id])
    }

    public static func invalidateDetailsCache(session: Session, courseID: String, id: String) throws {
        let context = try session.assignmentsManagedObjectContext()
        let key = detailsCacheKey(context, courseID: courseID, id: id)
        session.refreshScope.invalidateCache(key)
    }
    
    public static func predicate(courseID: String, assignmentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "courseID", courseID, "id", assignmentID)
    }
    
    public static func refresher(session: Session, courseID: String, assignmentID: String) throws -> Refresher {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let pred = predicate(courseID, assignmentID: assignmentID)
        let key = detailsCacheKey(context, courseID: courseID, id: assignmentID)
        let sync = Assignment.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(session: Session, courseID: String, assignmentID: String) throws -> ManagedObjectObserver<Assignment> {
        let pred = predicate(courseID, assignmentID: assignmentID)
        let context = try session.assignmentsManagedObjectContext()
        return try ManagedObjectObserver<Assignment>(predicate: pred, inContext: context)
    }
    
    public static func refreshDetailsSignalProducer(session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<[Assignment], NSError> {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let pred = predicate(courseID, assignmentID: assignmentID)
        
        return Assignment.syncSignalProducer(pred, inContext: context, fetchRemote: remote)     }
    
    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel where DVM: Equatable>(session: Session, courseID: String, assignmentID: String, detailsFactory: Assignment->[DVM]) throws -> TableViewDataSource {
        let obs = try observer(session, courseID: courseID, assignmentID: assignmentID)
        let collection = FetchedDetailsCollection<Assignment, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }
    
    public class DetailViewController: SoPersistent.TableViewController {
        private (set) public var observer: ManagedObjectObserver<Assignment>!
        
        public func prepare<DVM: TableViewCellViewModel where DVM: Equatable>(observer: ManagedObjectObserver<Assignment>, refresher: Refresher? = nil, detailsFactory: Assignment->[DVM]) {
            self.observer = observer
            let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: details)
        }
    }
}
