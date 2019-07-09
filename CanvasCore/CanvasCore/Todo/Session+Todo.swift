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



let kitModelName = "TodoKit"
let kitSubdomain = "TodoKit"
let kitFailedToLoadErrorCode = 10001
let kitFailedToLoadErrorDescription = "Failed to load \(kitModelName) NSManagedObjectModel"
let kitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the \(kitModelName) database file.", tableName: "Localizable", bundle: .core, value: "", comment: "CalendarKit Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current user Calendar Events
// ---------------------------------------------
extension Session {
    @objc func todosManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: kitModelName, inBundle: Bundle(for: Todo.self)) else {
            throw NSError(subdomain: kitSubdomain, code: kitFailedToLoadErrorCode, title: kitFailedToLoadErrorDescription, description: kitDBFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: kitModelName, model: model,
            localizedErrorDescription: kitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}
