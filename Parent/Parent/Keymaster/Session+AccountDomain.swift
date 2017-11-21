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
