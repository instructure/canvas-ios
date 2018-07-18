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

extension Rubric {
    
    public static func detailsCacheKey(_ context: NSManagedObjectContext, courseID: String, assignmentID: String) -> String {
        return cacheKey(context, [courseID, assignmentID])
    }
    
    public static func predicate(_ courseID: String, assignmentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "courseID", courseID, "assignmentID", assignmentID)
    }

    public static func refresher(_ session: Session, courseID: String, assignmentID: String) throws -> Refresher {
        let context = try session.assignmentsManagedObjectContext()
        let syncSubmission: SignalProducer<Void, NSError> = try Submission.refreshSignalProducer(session, courseID: courseID, assignmentID: assignmentID)
            .map { _ in () }
            .flatMapError { _ in SignalProducer.empty }
        
        let sync: SignalProducer<Void, NSError> = try Assignment.refreshDetailsSignalProducer(session, courseID: courseID, assignmentID: assignmentID)
            .map { _ in () }
            .concat(syncSubmission)
        
        let key = detailsCacheKey(context, courseID: courseID, assignmentID: assignmentID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func observer(_ session: Session, courseID: String, assignmentID: String) throws -> ManagedObjectObserver<Rubric> {
        let context = try session.assignmentsManagedObjectContext()
        return try ManagedObjectObserver<Rubric>(predicate: predicate(courseID, assignmentID: assignmentID), inContext: context)
    }

    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel>(_ session: Session, courseID: String, assignmentID: String, detailsFactory: @escaping (Rubric)->[DVM]) throws -> TableViewDataSource where DVM: Equatable {
        let obs = try observer(session, courseID: courseID, assignmentID: assignmentID)
        let collection = FetchedDetailsCollection<Rubric, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }
}

open class RubricDetailViewController: CanvasCore.TableViewController {
    fileprivate (set) open var observer: ManagedObjectObserver<Rubric>!
    
    open func prepare<DVM: TableViewCellViewModel>(_ observer: ManagedObjectObserver<Rubric>, refresher: Refresher? = nil, detailsFactory: @escaping (Rubric)->[DVM]) where DVM: Equatable {
        self.observer = observer
        let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
        self.refresher = refresher
        dataSource = CollectionTableViewDataSource(collection: details)
    }
}
