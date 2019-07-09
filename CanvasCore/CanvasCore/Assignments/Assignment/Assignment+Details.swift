//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit


import CoreData
import ReactiveSwift


extension Assignment {
    
    @objc public static func detailsCacheKey(_ context: NSManagedObjectContext, courseID: String, id: String) -> String {
        return cacheKey(context, [courseID, id])
    }

    @objc public static func invalidateDetailsCache(session: Session, courseID: String, id: String) throws {
        let context = try session.assignmentsManagedObjectContext()
        let key = detailsCacheKey(context, courseID: courseID, id: id)
        session.refreshScope.invalidateCache(key)
    }
    
    @objc public static func predicate(_ courseID: String, assignmentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "courseID", courseID, "id", assignmentID)
    }
    
    public static func refresher(_ session: Session, courseID: String, assignmentID: String) throws -> Refresher {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let pred = predicate(courseID, assignmentID: assignmentID)
        let key = detailsCacheKey(context, courseID: courseID, id: assignmentID)
        let sync = Assignment.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(_ session: Session, courseID: String, assignmentID: String) throws -> ManagedObjectObserver<Assignment> {
        let pred = predicate(courseID, assignmentID: assignmentID)
        let context = try session.assignmentsManagedObjectContext()
        return try ManagedObjectObserver<Assignment>(predicate: pred, inContext: context)
    }
    
    public static func refreshDetailsSignalProducer(_ session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<[Assignment], NSError> {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let pred = predicate(courseID, assignmentID: assignmentID)
        
        return Assignment.syncSignalProducer(pred, inContext: context, fetchRemote: remote)     }
    
    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel>(_ session: Session, courseID: String, assignmentID: String, detailsFactory: @escaping (Assignment)->[DVM]) throws -> TableViewDataSource where DVM: Equatable {
        let obs = try observer(session, courseID: courseID, assignmentID: assignmentID)
        let collection = FetchedDetailsCollection<Assignment, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }
}

open class AssignmentDetailViewController: CanvasCore.TableViewController {
    fileprivate (set) open var observer: ManagedObjectObserver<Assignment>!
    
    open func prepare<DVM: TableViewCellViewModel>(_ observer: ManagedObjectObserver<Assignment>, refresher: Refresher? = nil, detailsFactory: @escaping (Assignment)->[DVM]) where DVM: Equatable {
        self.observer = observer
        let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
        self.refresher = refresher
        dataSource = CollectionTableViewDataSource(collection: details)
    }
}
