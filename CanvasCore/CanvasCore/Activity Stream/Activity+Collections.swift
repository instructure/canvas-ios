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
