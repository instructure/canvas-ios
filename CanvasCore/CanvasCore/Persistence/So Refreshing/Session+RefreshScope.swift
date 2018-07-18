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


