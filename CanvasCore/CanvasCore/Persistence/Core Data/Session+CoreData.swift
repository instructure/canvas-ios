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
    
    

import Foundation


import CoreData

public struct StoreID {
    let storeName: String
    let model: NSManagedObjectModel
    
    let localizedErrorDescription: String

    /**
        Allows a NSManagedObjectContext to be associated with a session.
        
        - Parameter storeName: Make sure this is unique and a valid file name. i.e. '231459-Enrollments'
        - Parameter modelFileName: This is the base name of the `.xcdatamodel` file.
        - Parameter localizedErrorDescription: This will be used if there is an error loading the store. It should be user-presentable and localized.
    */
    public init(storeName: String, modelFileName: String, modelFileBundle: Bundle, localizedErrorDescription: String) {
        self.storeName = storeName
        self.localizedErrorDescription = localizedErrorDescription
        
        guard let model = NSManagedObjectModel(named: modelFileName, inBundle: modelFileBundle) else {
            ❨╯°□°❩╯⌢"Where is the \(modelFileName).xcdatamodeld?"
        }
        self.model = model
    }
    
    public init(storeName: String, model: NSManagedObjectModel, localizedErrorDescription: String) {
        self.storeName = storeName
        self.model = model
        self.localizedErrorDescription = localizedErrorDescription
    }
}


extension Session {
    internal struct AssociatedObjectKeys {
        static var contextByStoreID = "who cares"
        static var storeType = "whatevs"
    }
    
    internal var contextsByStoreID: NSMutableDictionary {
        get {
            guard let box: NSMutableDictionary = getAssociatedObject(&AssociatedObjectKeys.contextByStoreID) else {
                let box = NSMutableDictionary()
                setAssociatedObject(box, forKey: &AssociatedObjectKeys.contextByStoreID)
                return box
            }
            
            return box
        }
        set {
            setAssociatedObject(newValue, forKey: &AssociatedObjectKeys.storeType)
        }
    }

    public var storeType: String {
        get {
            guard let box: NSString = getAssociatedObject(&AssociatedObjectKeys.storeType) else {
                return NSSQLiteStoreType
            }
            return String(box)
        }
        set {
            setAssociatedObject(newValue as NSString, forKey: &AssociatedObjectKeys.storeType)
        }
    }

    public func managedObjectContext(_ id: StoreID) throws -> NSManagedObjectContext {
        let contextsByStoreID = self.contextsByStoreID
        guard let context = contextsByStoreID[id.storeName] as? NSManagedObjectContext else {
            let storeURL = localStoreDirectoryURL.appendingPathComponent("\(id.storeName).sqlite")
            print(storeURL)

            do {
                let context = try NSManagedObjectContext(storeURL: storeURL, model: id.model, concurrencyType: .mainQueueConcurrencyType, storeType: storeType) {
                    // called if the persistent store was reset due to incompatability
                    self.refreshScope.invalidateAllCaches()
                }
                context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
                contextsByStoreID[id.storeName] = context
                return context
            } catch let e as NSError {
                let title = NSLocalizedString("Data Error", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Error title for a persistence related data failure")
                throw NSError(subdomain: id.storeName, code: e.code, sessionID: sessionID, apiURL: storeURL, title: title, description: id.localizedErrorDescription, failureReason: e.localizedDescription)
            }
        }
        
        return context
    }
}
