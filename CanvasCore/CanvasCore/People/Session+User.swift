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
