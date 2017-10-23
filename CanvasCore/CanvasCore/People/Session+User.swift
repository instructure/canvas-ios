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
    
    


import CoreData



let peepKitModelName = "Peeps"
let peepKitStoreName = "ObservedUsers"
let peepKitSubdomain = "PeepKit"
let peepKitFailedToLoadErrorCode = 10001
let peepKitFailedToLoadErrorDescription = "Failed to load \(peepKitModelName) NSManagedObjectModel"
let peepKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the PeepKit database file.", tableName: "Localizable", bundle: .core, value: "", comment: "PeepKit Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current user observees
// ---------------------------------------------
extension Session {
    func observeesManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "Peeps", inBundle: Bundle(for: User.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: peepKitSubdomain, code: peepKitFailedToLoadErrorCode, title: peepKitFailedToLoadErrorDescription, description: peepKitFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: peepKitStoreName, model: model,
            localizedErrorDescription: peepKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}


private let peepsErrorMessage = NSLocalizedString("There was an error loading the Users cache.", tableName: "Localizable", bundle: .core, value: "", comment: "An error message shown when the Users cache file fails to load")

// ---------------------------------------------
// MARK: - Session for current user observees
// ---------------------------------------------
extension Session {
    public func peepsManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "Peeps", inBundle: .core) else {
            throw NSError(subdomain: "Peeps", code: 10002, sessionID: sessionID, apiURL: nil, title: nil, description: peepsErrorMessage, failureReason: "Error loading Peeps.xcdatamodel", data: nil)
        }

        let storeID = StoreID(storeName: "Peeps", model: model, localizedErrorDescription: peepsErrorMessage)
        
        return try managedObjectContext(storeID)
    }
}
