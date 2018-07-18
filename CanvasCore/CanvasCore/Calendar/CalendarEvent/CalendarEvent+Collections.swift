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
