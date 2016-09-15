//
//  AccountDomain.swift
//  Assignments
//
//  Created by Brandon Pluim on 1/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
//import CakeBox
//import ThreeLegit
import ReactiveCocoa
import JaSON
//import SoColorful


final class AccountDomain: NSManagedObject {
}

extension AccountDomain: SynchronizedModel {
    static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let name: String = try json <| "name"
        return NSPredicate(format: "%K == %@", "name", name)
    }
    static func updateValues(model: AccountDomain, json: JSONObject) throws {
        try model.name = json <| "name"
        try model.domain = json <| "domain"
    }
}


extension AccountDomain {
    static func getAccountDomainList() throws -> SignalProducer<JSONObject, NSError> {
        let url = NSURL(string: "https://canvas.instructure.com/api/v1/accounts/search?per_page=50")!
        let request = NSURLRequest(URL: url)
        return NSURLSession.sharedSession().paginatedJSONSignalProducer(request)
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
    
    return try AccountDomain.tableViewController(nil, sortDescriptors: ["name".ascending], context: context, remote: AccountDomain.getAccountDomainList())  { ColorfulViewModel(name: $0.name) }
}
