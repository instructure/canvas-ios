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

