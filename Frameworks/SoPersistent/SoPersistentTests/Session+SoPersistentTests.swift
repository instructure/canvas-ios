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
    
    

import TooLegit
import SoPersistent
import SoLazy
import CoreData

extension Session {
    func soPersistentTestsManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "DataModel", inBundle: Bundle(for: Panda.self))?.mutableCopy() as? NSManagedObjectModel else { ❨╯°□°❩╯⌢"problems?" }

        let storeID = StoreID(storeName: "SoPersistentTests", model: model,
            localizedErrorDescription: NSLocalizedString("There was a problem loading the SoPersistentTests database file.", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "SoPersistent Tests database fails"))
        
        return try managedObjectContext(storeID)
    }
}
