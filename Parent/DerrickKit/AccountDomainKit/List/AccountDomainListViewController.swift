//
//  AccountDomainListViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 1/9/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
//import CakeBox
import CoreData
//import ThreeLegit
import ReactiveCocoa
import JaSON

extension AccountDomain {
    func colorfulViewModel() -> ColorfulViewModel {
        return ColorfulViewModel(name: name)
    }
}

public func accountDomainListViewController() throws -> UIViewController {
    var localStoreDirectoryURL: NSURL {
        guard let lib = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first else { fatalError("GASP! There were no user library search paths") }
        let fileURL = NSURL(fileURLWithPath: lib)
        
        let url = fileURL.URLByAppendingPathComponent("AccountDomains")
        let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
    
    // Holiday Extravaganza TODO: SoErroneous
    guard let model = NSManagedObjectModel(named: "AccountDomain", inBundle: NSBundle(forClass: AccountDomain.self)) else { fatalError("problems?") }
    let storeURL = localStoreDirectoryURL.URLByAppendingPathComponent("accountDomains.sqlite")
    
    let context = try NSManagedObjectContext(storeURL: storeURL, model: model)
    
    return try AccountDomain.tableViewController(nil, sortDescriptors: ["name".ascending], context: context, remote: AccountDomain.getAccountDomainList())  { $0.colorfulViewModel() }
}
