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
    
    


import CoreData

import CanvasCore

let alertKitModelName = "ObserverAlertKit"
let alertKitStoreName = "ObserverAlertKit"
let alertKitSubdomain = "ObserverAlertKit"
let alertKitFailedToLoadErrorCode = 10001
let alertKitFailedToLoadErrorDescription = "Failed to load \(alertKitModelName) NSManagedObjectModel"
let alertKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the AlertKit database file.", comment: "AlertKit Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current alert context
// ---------------------------------------------
extension Session {
    func alertsManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: alertKitModelName, inBundle: Bundle(for: Alert.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: alertKitSubdomain, code: alertKitFailedToLoadErrorCode, title: alertKitFailedToLoadErrorDescription, description: alertKitFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: alertKitStoreName, model: model,
                              localizedErrorDescription: alertKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}
