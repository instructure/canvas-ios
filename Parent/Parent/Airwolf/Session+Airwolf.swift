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
    
    

import Foundation

import CoreData

import CanvasCore

extension Session {
    public func airwolfManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "Airwolf", inBundle: Bundle(for: Student.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: "Airwolf", description: "Failed to load Airwolf NSManagedObjectModel")
        }

        let storeID = StoreID(storeName: "Airwolf", model: model, localizedErrorDescription: NSLocalizedString("There was a problem loading the database.", comment: "Airwolf database error message"))

        return try managedObjectContext(storeID)
    }
}
