//
//  Session+RefreshScope.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 4/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoLazy

private let SoRefreshingStoreID = StoreID(storeName: "SoRefreshing", modelFileName: "SoRefreshing", modelFileBundle: NSBundle(forClass: Refresh.self), localizedErrorDescription: NSLocalizedString("Error loading cache management database.", comment: "error message for when the cache management database fails to load"))


extension Session {
    private enum Associated {
        private static var refreshScope: UInt8 = 1
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


