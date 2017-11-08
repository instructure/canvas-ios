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
