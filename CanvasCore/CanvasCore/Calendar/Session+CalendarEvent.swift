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



let calendarKitModelName = "CalendarKit"
let calendarKitSubdomain = "CalendarKit"
let calendarKitFailedToLoadErrorCode = 10001
let calendarKitFailedToLoadErrorDescription = "Failed to load \(calendarKitModelName) NSManagedObjectModel"
let calendarKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the CalendarKit database file.", tableName: "Localizable", bundle: .core, value: "", comment: "CalendarKit Database Load Failure Message")

extension Session {
    public func calendarEventsManagedObjectContext(_ scope: String? = nil) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: calendarKitModelName, inBundle: Bundle(for: CalendarEvent.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: calendarKitSubdomain, code: calendarKitFailedToLoadErrorCode, title: calendarKitFailedToLoadErrorDescription, description: calendarKitFailedToLoadErrorDescription)
        }

        let storeName = scope == nil ? calendarKitModelName : "\(calendarKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model,
            localizedErrorDescription: calendarKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}

