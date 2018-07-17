//
// Copyright (C) 2017-present Instructure, Inc.
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



extension Session {
    var suchActivityManagedObjectContext: NSManagedObjectContext {
        let model = NSManagedObjectModel(named: "SuchActivity", inBundle: .core)!
        
        let storeID = StoreID(storeName: "SuchActivity", model: model, localizedErrorDescription: "Error loading SuchActivity database file")
        
        return try! managedObjectContext(storeID)
    }
}
