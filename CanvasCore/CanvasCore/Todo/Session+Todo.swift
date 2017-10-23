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



let kitModelName = "TodoKit"
let kitSubdomain = "TodoKit"
let kitFailedToLoadErrorCode = 10001
let kitFailedToLoadErrorDescription = "Failed to load \(kitModelName) NSManagedObjectModel"
let kitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the \(kitModelName) database file.", tableName: "Localizable", bundle: .core, value: "", comment: "CalendarKit Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current user Calendar Events
// ---------------------------------------------
extension Session {
    func todosManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: kitModelName, inBundle: Bundle(for: Todo.self)) else {
            throw NSError(subdomain: kitSubdomain, code: kitFailedToLoadErrorCode, title: kitFailedToLoadErrorDescription, description: kitDBFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: kitModelName, model: model,
            localizedErrorDescription: kitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}
