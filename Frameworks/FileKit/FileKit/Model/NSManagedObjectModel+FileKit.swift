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
        let fileKitBundle = NSBundle(forClass: File.self)
        guard let fileMOM = NSManagedObjectModel.mergedModelFromBundles([fileKitBundle]) else {
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
