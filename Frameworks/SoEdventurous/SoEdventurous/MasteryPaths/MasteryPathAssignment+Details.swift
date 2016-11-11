//
//  MasteryPathAssignment+Details.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 10/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import TooLegit

extension MasteryPathAssignment {
    public static func observer(session: Session, id: String) throws -> ManagedObjectObserver<MasteryPathAssignment> {
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        let context = try session.soEdventurousManagedObjectContext()
        return try ManagedObjectObserver<MasteryPathAssignment>(predicate: predicate, inContext: context)
    }

    public class DetailViewController: SoPersistent.TableViewController {
        private (set) public var observer: ManagedObjectObserver<MasteryPathAssignment>!

        public func prepare<DVM: TableViewCellViewModel where DVM: Equatable>(observer: ManagedObjectObserver<MasteryPathAssignment>, detailsFactory: MasteryPathAssignment->[DVM]) {
            self.observer = observer
            let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
            dataSource = CollectionTableViewDataSource(collection: details)
        }
    }
}
