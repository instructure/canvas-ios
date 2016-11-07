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
    
    

import Foundation
import TooLegit
import CoreData
import SoPersistent
import SoLazy

extension AlertThreshold {
    static func studentPredicate(studentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "studentID", studentID)
    }
}

// ---------------------------------------------
// MARK: - Alerts collection for current observee
// ---------------------------------------------
extension AlertThreshold {
    public static func collectionOfAlertThresholds(session: Session, studentID: String) throws -> FetchedCollection<AlertThreshold> {
        let predicate = studentPredicate(studentID)
        let frc = AlertThreshold.fetchedResults(predicate, sortDescriptors: ["type".ascending], sectionNameKeypath: nil, inContext: try session.alertsManagedObjectContext())

        return try FetchedCollection<AlertThreshold>(frc: frc)
    }

    public static func refresher(session: Session) throws -> Refresher {
        let remote = try AlertThreshold.getAllAlertThresholds(session)
        let context = try session.alertsManagedObjectContext()
        let sync = AlertThreshold.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<AlertThreshold>
}
