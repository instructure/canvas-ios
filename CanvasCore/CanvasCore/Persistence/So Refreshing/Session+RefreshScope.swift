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
    
    




internal let SoRefreshingStoreID = StoreID(storeName: "SoRefreshing", modelFileName: "SoRefreshing", modelFileBundle: Bundle(for: Refresh.self), localizedErrorDescription: NSLocalizedString("Error loading cache management database.", tableName: "Localizable", bundle: .core, value: "", comment: "error message for when the cache management database fails to load"))


extension Session {
    fileprivate enum Associated {
        fileprivate static var refreshScope: UInt8 = 1
    }
    
    public var refreshScope: RefreshScope {
        if let scope: RefreshScope = getAssociatedObject(&Associated.refreshScope) {
            return scope
        }
        
        do {
            let context = try managedObjectContext(SoRefreshingStoreID)
            let scope = RefreshScope(context: context)
            setAssociatedObject(scope, forKey: &Associated.refreshScope)
            return scope
        } catch let e as NSError {
            ❨╯°□°❩╯⌢"Can't get the context for the refresh scope! – \(e.reportDescription)"
        }
    }
}


