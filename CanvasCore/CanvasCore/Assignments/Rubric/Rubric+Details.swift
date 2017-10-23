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
