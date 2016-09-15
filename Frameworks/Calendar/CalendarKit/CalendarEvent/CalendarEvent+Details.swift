//
//  CalendarEvent+Details.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import TooLegit
import SoPersistent
import CoreData
import ReactiveCocoa

extension CalendarEvent {
    public static func predicate(calendarEventID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", calendarEventID)
    }

    public static func refresher(session: Session, calendarEventID: String) throws -> Refresher {
        let context = try session.calendarEventsManagedObjectContext()
        let remote = try CalendarEvent.getCalendarEvent(session, calendarEventID: calendarEventID).map { [$0] }
        let pred = predicate(calendarEventID)
        let sync = CalendarEvent.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
        let key = cacheKey(context, [calendarEventID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(session: Session, calendarEventID: String) throws -> ManagedObjectObserver<CalendarEvent> {
        let pred = predicate(calendarEventID)
        let context = try session.calendarEventsManagedObjectContext()
        return try ManagedObjectObserver<CalendarEvent>(predicate: pred, inContext: context)
    }

    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel where DVM: Equatable>(session: Session, calendarEventID: String, detailsFactory: CalendarEvent->[DVM]) throws -> TableViewDataSource {
        let obs = try observer(session, calendarEventID: calendarEventID)
        let collection = FetchedDetailsCollection<CalendarEvent, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }

    public class DetailViewController: SoPersistent.TableViewController {
        private (set) public var observer: ManagedObjectObserver<CalendarEvent>!

        public func prepare<DVM: TableViewCellViewModel where DVM: Equatable>(observer: ManagedObjectObserver<CalendarEvent>, refresher: Refresher? = nil, detailsFactory: CalendarEvent->[DVM]) {
            self.observer = observer
            let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: details)
        }
    }
}