//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

import CoreData



let pageKitModelName = "PageKit"
let pageKitStoreName = "PageKit"

extension Session {
    @objc func pagesManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: pageKitModelName, inBundle: Bundle(for: Page.self))?.mutableCopy() as? NSManagedObjectModel else {
            fatalError("Could not load Page model in Session+Page extension")
        }
        
        let storeID = StoreID(storeName: pageKitStoreName, model: model, localizedErrorDescription: NSLocalizedString("There was a problem loading the Pages database file.", tableName: "Localizable", bundle: .core, value: "", comment: "Page list fails"))
        
        return try managedObjectContext(storeID)
    }
}
