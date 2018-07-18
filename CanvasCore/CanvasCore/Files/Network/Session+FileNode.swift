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



let fileKitModelName = "FileKit"
let fileKitSubdomain = "FileKit"
let fileKitFailedToLoadErrorCode = 10001
let fileKitFailedToLoadErrorDescription = "Failed to load \(fileKitModelName) NSManagedObjectModel"
let fileKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the FileKit database file.", tableName: "Localizable", bundle: .core, value: "", comment: "FileKit Database Load Failure Message")

extension NSManagedObjectModel {
    static func filesManagedObjectModel() throws -> NSManagedObjectModel {
        guard let model = NSManagedObjectModel(named: fileKitModelName, inBundle: Bundle(for: FileNode.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: fileKitSubdomain, code: fileKitFailedToLoadErrorCode, title: fileKitFailedToLoadErrorDescription, description: fileKitFailedToLoadErrorDescription)
        }
        return model
    }
}

extension Session {
    public func filesManagedObjectContext() throws -> NSManagedObjectContext {
        let model = try NSManagedObjectModel.filesManagedObjectModel()
        let storeID = StoreID(storeName: fileKitModelName, model: model,
                              localizedErrorDescription: fileKitDBFailedToLoadErrorDescription)
        
        return try managedObjectContext(storeID)
    }
}
