//
// Copyright (C) 2017-present Instructure, Inc.
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

extension Activity {
    var daySectionTitle: String {
        return Activity.sectionTitleDateFormatter.string(from: updatedAt as Date)
    }

    @nonobjc public static var sectionTitleDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
}

extension Activity {
    public static func predicate(forSupportedActivitiesInContext context: ContextID) -> NSPredicate {
        let supportedTypePredicate = NSPredicate(format: "%K != %@ && %K != %@ && %K != %@", "type", ActivityType.conference.rawValue, "type", ActivityType.collaboration.rawValue, "type", ActivityType.assessmentRequest.rawValue)

        if context != .currentUser {
            let contextPredicate = NSPredicate(format: "%K == %@", "context", context.canvasContextID)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [contextPredicate, supportedTypePredicate])
        } else {
            return supportedTypePredicate
        }
    }
    
    public static func collection(session: Session, context: ContextID = .currentUser) throws -> FetchedCollection<Activity> {
        let predicate = Activity.predicate(forSupportedActivitiesInContext: context)
        let moc = session.suchActivityManagedObjectContext

        return try FetchedCollection(frc: moc.fetchedResults(predicate, sortDescriptors: ["updatedAt".descending, "id".ascending], sectionNameKeypath: "daySectionTitle"))
    }
    
    
    public static func refresher(session: Session, context: ContextID = .currentUser) throws -> Refresher {
        let predicate = Activity.predicate(forSupportedActivitiesInContext: context)
        let moc = session.suchActivityManagedObjectContext
        let sync = try Activity.syncSignalProducer(predicate, inContext: moc, fetchRemote: Activity.getActivity(session: session, context: context))
        
        let key = cacheKey(moc, [context.canvasContextID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}
