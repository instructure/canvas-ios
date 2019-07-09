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

import Foundation

import CoreData

import CanvasCore

extension AlertThreshold {
    @objc static func studentPredicate(_ studentID: String) -> NSPredicate {
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

    public static func refresher(_ session: Session, studentID: String) throws -> Refresher {
        let remote = try AlertThreshold.getAlertThresholds(session, studentID: studentID)
        let context = try session.alertsManagedObjectContext()
        let sync = AlertThreshold.syncSignalProducer(inContext: context, fetchRemote: remote).on(failed: {error in
            if error.code == 401 {
                AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
            }
        })

        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key, ttl: ParentAppRefresherTTL)
    }
}
