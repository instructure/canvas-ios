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




// ---------------------------------------------
// MARK: - Calendar Events collection for current user
// ---------------------------------------------
extension CalendarEvent {
    public static func predicate(_ startDate: Date, endDate: Date, contextCodes: [String]) -> NSPredicate {
        let contextCodesPredicate = NSPredicate(format: "%K IN %@ OR %K IN %@", "effectiveContextCode", contextCodes, "contextCode", contextCodes)
        let personalCalendarPredicate = NSPredicate(format: "%K CONTAINS %@ OR %K CONTAINS %@", "effectiveContextCode", "user_", "contextCode", "user_")
        let contextsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [contextCodesPredicate, personalCalendarPredicate])

        let datesPredicate = NSPredicate(format: "%K < %@ AND %@ <= %K", "startAt", endDate as CVarArg, startDate as CVarArg, "endAt")
        let hiddenPredicate = NSPredicate(format: "%K != %@", "hidden", NSNumber(value: true as Bool))

        return NSCompoundPredicate(andPredicateWithSubpredicates: [contextsPredicate, datesPredicate, hiddenPredicate])
    }

    public static func collectionByDueDate(_ session: Session, studentID: String? = nil, startDate: Date, endDate: Date, contextCodes: [String]) throws -> FetchedCollection<CalendarEvent> {
        let context = studentID == nil ? try session.calendarEventsManagedObjectContext() : try session.calendarEventsManagedObjectContext(studentID)
        return try collectionByDueDate(session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes, context: context)
    }

    public static func refresher(_ session: Session, startDate: Date, endDate: Date, contextCodes: [String]) throws -> Refresher {
        let predicate = CalendarEvent.predicate(startDate, endDate: endDate, contextCodes: contextCodes)
        let remote = try CalendarEvent.getAllCalendarEvents(session, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        let context = try session.calendarEventsManagedObjectContext()
        let sync = CalendarEvent.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)
        let key = cacheKey(context, [startDate.yyyyMMdd, endDate.yyyyMMdd] + contextCodes.sorted())
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}


// ---------------------------------------------
// MARK: - Helpers
// ---------------------------------------------
extension CalendarEvent {
    fileprivate static func collectionByDueDate(_ session: Session, studentID: String? = nil, startDate: Date, endDate: Date, contextCodes: [String], context: NSManagedObjectContext) throws -> FetchedCollection<CalendarEvent> {
        let predicate = CalendarEvent.predicate(startDate, endDate: endDate, contextCodes: contextCodes)
        let sortDescriptors = ["endAt".ascending, "id".ascending]
        let frc: NSFetchedResultsController<CalendarEvent> = context.fetchedResults(predicate, sortDescriptors: sortDescriptors, sectionNameKeypath: "allDayDate")
        let titleFunction: (String?)->String? = { $0.flatMap {
            if let date = CalendarEvent.dayDateFormatter.date(from: $0) {
                return CalendarEvent.sectionTitleDateFormatter.string(from: date)
            }

            return "Unknown Date"
            }
        }

        return try FetchedCollection<CalendarEvent>(frc: frc, titleForSectionTitle:titleFunction)
    }
}
