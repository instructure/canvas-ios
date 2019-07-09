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

import CanvasCore

extension Alert {
    @objc public static func unreadPredicate() -> NSPredicate {
        return NSPredicate(format: "%K == false", "read")
    }
    @objc public static func undismissedPredicate() -> NSPredicate {
        return NSPredicate(format: "%K == false", "dismissed")
    }
    @objc public static func observeePredicate(_ observeeID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "studentID", observeeID)
    }
}

// ---------------------------------------------
// MARK: - Alerts collection for current observee
// ---------------------------------------------
extension Alert {
    public static func collectionOfObserveeAlerts(_ session: Session, observeeID: String) throws -> FetchedCollection<Alert> {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [Alert.undismissedPredicate(), Alert.observeePredicate(observeeID)])
        let context = try session.alertsManagedObjectContext()

        return try FetchedCollection<Alert>(frc:
            context.fetchedResults(predicate, sortDescriptors: ["actionDate".descending, "title".ascending])
        )
    }

    public static func refresher(_ session: Session, observeeID: String) throws -> Refresher {
        let predicate = Alert.observeePredicate(observeeID)
        let remote = try Alert.getAlerts(session, studentID: observeeID)
        let context = try session.alertsManagedObjectContext()
        let sync = Alert.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)
            .on(failed: { error in
                if error.code == 401 {
                    AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
                }
            })

        let key = self.cacheKey(context, [session.user.id, observeeID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key, ttl: ParentAppRefresherTTL)
    }
}
