//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

internal let SoRefreshingStoreID = StoreID(storeName: "SoRefreshing", modelFileName: "SoRefreshing", modelFileBundle: Bundle(for: Refresh.self), localizedErrorDescription: NSLocalizedString("Error loading cache management database.", tableName: "Localizable", bundle: .core, value: "", comment: "error message for when the cache management database fails to load"))


extension Session {
    fileprivate enum Associated {
        fileprivate static var refreshScope: UInt8 = 1
    }
    
    @objc public var refreshScope: RefreshScope {
        if let scope: RefreshScope = getAssociatedObject(&Associated.refreshScope) {
            return scope
        }
        
        do {
            let context = try managedObjectContext(SoRefreshingStoreID)
            let scope = RefreshScope(context: context)
            setAssociatedObject(scope, forKey: &Associated.refreshScope)
            return scope
        } catch let e as NSError {
            fatalError("Can't get the context for the refresh scope! – \(e.reportDescription)")
        }
    }
}


