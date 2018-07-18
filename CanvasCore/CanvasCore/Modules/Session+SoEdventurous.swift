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



private let modelName = "SoEdventurous"
private let dbFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the SoEdventurous database file.", comment: "SoEdventurous database load failure message")

extension Session {
    public func soEdventurousManagedObjectContext() throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel(named: modelName, inBundle: Bundle(for: Module.self))?.mutableCopy() as! NSManagedObjectModel
        let storeID = StoreID(storeName: modelName, model: model, localizedErrorDescription: dbFailedToLoadErrorDescription)
        return try managedObjectContext(storeID)
    }
}
