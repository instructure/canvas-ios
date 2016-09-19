//
//  Session+CalendarEvent.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

let calendarKitModelName = "CalendarKit"
let calendarKitSubdomain = "CalendarKit"
let calendarKitFailedToLoadErrorCode = 10001
let calendarKitFailedToLoadErrorDescription = "Failed to load \(calendarKitModelName) NSManagedObjectModel"
let calendarKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the CalendarKit database file.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.CalendarKit")!, value: "", comment: "CalendarKit Database Load Failure Message")

extension Session {
    public func calendarEventsManagedObjectContext(scope: String? = nil) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: calendarKitModelName, inBundle: NSBundle(forClass: CalendarEvent.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: calendarKitSubdomain, code: calendarKitFailedToLoadErrorCode, title: calendarKitFailedToLoadErrorDescription, description: calendarKitFailedToLoadErrorDescription)
        }

        let storeName = scope == nil ? calendarKitModelName : "\(calendarKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model,
            localizedErrorDescription: calendarKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}

