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

import CanvasCore

let accountDomainModelName = "Keymaster"
let accountDomainSubdomain = "Keymaster"
let accountDomainFailedToLoadErrorCode = 10001
let accountDomainFailedToLoadErrorDescription = "Failed to load \(accountDomainModelName) NSManagedObjectModel"
let accountDomainDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the AccountDomain database file.", tableName: "Localizable", bundle: .parent, value: "", comment: "AccountDomain Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current user Calendar Events
// ---------------------------------------------
extension Session {
    func accountDomainsManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: accountDomainModelName, inBundle: Bundle(for: AccountDomain.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: accountDomainSubdomain, code: accountDomainFailedToLoadErrorCode, title: accountDomainFailedToLoadErrorDescription, description: accountDomainFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: accountDomainModelName, model: model,
            localizedErrorDescription: accountDomainDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}
