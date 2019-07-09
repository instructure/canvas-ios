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




let assignmentKitModelName = "AssignmentKit"
let assignmentKitSubdomain = "AssignmentKit"
let assignmentKitFailedToLoadErrorCode = 10001
let assignmentKitFailedToLoadErrorDescription = "Failed to load \(assignmentKitModelName) NSManagedObjectModel"
let assignmentKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the AssignmentKit database file.", tableName: "Localizable", bundle: .core, value: "", comment: "AssignmentKit database load failure message")

extension Session {
    @objc public func assignmentsManagedObjectContext(_ scope: String? = nil) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: assignmentKitModelName, inBundle: Bundle(for: Assignment.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: assignmentKitSubdomain, code: assignmentKitFailedToLoadErrorCode, title: assignmentKitFailedToLoadErrorDescription, description: assignmentKitDBFailedToLoadErrorDescription)
        }

        let storeName = scope == nil ? assignmentKitModelName : "\(assignmentKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model, localizedErrorDescription: assignmentKitDBFailedToLoadErrorDescription)
        
        return try managedObjectContext(storeID)
    }
}
