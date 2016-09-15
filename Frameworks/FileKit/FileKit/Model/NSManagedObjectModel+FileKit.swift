//
//  NSManagedObjectModel+FileKit.swift
//  FileKit
//
//  Created by Derrick Hathaway on 1/21/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoLazy

// being explicit here, cuz when Swift 3 rolls around it will want to 
// lowercase the cases!
private enum Entities: String {
    case File = "File"
    case Upload = "Upload"
    case FileUpload = "FileUpload"
}

// comments
extension NSManagedObjectModel {
    
    @warn_unused_result(message="The File entity is added to a copy of the receiver. The receiver is immutable.")
    public func loadingFileEntity() -> NSManagedObjectModel {
        guard let fileMOM = NSManagedObjectModel(named: "FileKit", inBundle: NSBundle(forClass: File.self)) else {
            ❨╯°□°❩╯⌢"The FileKit.xcdatamodel is noticably absent"
        }

        return loadStubbedEntities([.File, .Upload, .FileUpload], fromModel: fileMOM)
    }

    private func loadStubbedEntities(entities: [Entities], fromModel model: NSManagedObjectModel) -> NSManagedObjectModel {
        guard let plusEntities = self.copy() as? NSManagedObjectModel else { ❨╯°□°❩╯⌢"This should never fail" }

        for name in entities.map({ $0.rawValue }) {
            guard let entity = model.entitiesByName[name] else {
                ❨╯°□°❩╯⌢"Must have a `\(name)` entity"
            }

            guard let stubEntity = plusEntities.entitiesByName[name] else { ❨╯°□°❩╯⌢"You must supply a stub `\(name)` entity" }

            stubEntity.properties = entity.properties.map { prop in
                guard let p = prop.copy() as? NSPropertyDescription else { ❨╯°□°❩╯⌢"Y U No NSEntityDescription?" }
                return p
            }
        }

        return plusEntities
    }

}
