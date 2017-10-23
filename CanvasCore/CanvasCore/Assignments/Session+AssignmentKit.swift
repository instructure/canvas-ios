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




let assignmentKitModelName = "AssignmentKit"
let assignmentKitSubdomain = "AssignmentKit"
let assignmentKitFailedToLoadErrorCode = 10001
let assignmentKitFailedToLoadErrorDescription = "Failed to load \(assignmentKitModelName) NSManagedObjectModel"
let assignmentKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the AssignmentKit database file.", tableName: "Localizable", bundle: .core, value: "", comment: "AssignmentKit database load failure message")

extension Session {
    public func assignmentsManagedObjectContext(_ scope: String? = nil) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: assignmentKitModelName, inBundle: Bundle(for: Assignment.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: assignmentKitSubdomain, code: assignmentKitFailedToLoadErrorCode, title: assignmentKitFailedToLoadErrorDescription, description: assignmentKitDBFailedToLoadErrorDescription)
        }

        let storeName = scope == nil ? assignmentKitModelName : "\(assignmentKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model, localizedErrorDescription: assignmentKitDBFailedToLoadErrorDescription)
        
        return try managedObjectContext(storeID)
    }
}
