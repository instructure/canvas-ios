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
import ReactiveSwift

extension CalendarEvent {
    public static func predicate(_ calendarEventID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", calendarEventID)
    }

    public static func refresher(_ session: Session, calendarEventID: String) throws -> Refresher {
        let context = try session.calendarEventsManagedObjectContext()
        let remote = try CalendarEvent.getCalendarEvent(session, calendarEventID: calendarEventID).map { [$0] }
        let pred = predicate(calendarEventID)
        let sync = CalendarEvent.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
        let key = cacheKey(context, [calendarEventID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(_ session: Session, calendarEventID: String) throws -> ManagedObjectObserver<CalendarEvent> {
        let pred = predicate(calendarEventID)
        let context = try session.calendarEventsManagedObjectContext()
        return try ManagedObjectObserver<CalendarEvent>(predicate: pred, inContext: context)
    }

    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel>(_ session: Session, calendarEventID: String, detailsFactory: @escaping (CalendarEvent)->[DVM]) throws -> TableViewDataSource where DVM: Equatable {
        let obs = try observer(session, calendarEventID: calendarEventID)
        let collection = FetchedDetailsCollection<CalendarEvent, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }

}

open class CalendarEventDetailViewController: CanvasCore.TableViewController {
    fileprivate (set) open var observer: ManagedObjectObserver<CalendarEvent>!
    
    open func prepare<DVM: TableViewCellViewModel>(_ observer: ManagedObjectObserver<CalendarEvent>, refresher: Refresher? = nil, detailsFactory: @escaping (CalendarEvent)->[DVM]) where DVM: Equatable {
        self.observer = observer
        let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
        self.refresher = refresher
        dataSource = CollectionTableViewDataSource(collection: details)
    }
}
