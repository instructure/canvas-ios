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

import CoreData

import CanvasCore

extension AlertThreshold {
    static func studentPredicate(_ studentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "studentID", studentID)
    }
}

// ---------------------------------------------
// MARK: - Alerts collection for current observee
// ---------------------------------------------
extension AlertThreshold {
    public static func collectionOfAlertThresholds(_ session: Session, studentID: String) throws -> FetchedCollection<AlertThreshold> {
        let predicate = studentPredicate(studentID)
        let context = try session.alertsManagedObjectContext()

        return try FetchedCollection<AlertThreshold>(frc:
            context.fetchedResults(predicate, sortDescriptors: ["type".ascending])
        )
    }

    public static func refresher(_ session: Session) throws -> Refresher {
        let remote = try AlertThreshold.getAllAlertThresholds(session)
        let context = try session.alertsManagedObjectContext()
        let sync = AlertThreshold.syncSignalProducer(inContext: context, fetchRemote: remote).on(failed: {error in
            if error.code == 401 {
                AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
            }
        })

        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}
