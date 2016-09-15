//
//  UserObserveeListViewController.swift
//  Peeps
//
//  Created by Brandon Pluim on 1/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import TooLegit
import CoreData
import SoPersistent
import SoLazy

public func userObserveeListViewController<VM: TableViewCellViewModel>(session: Session, viewModelFactory: UserProtocol->VM, didSelectItem: (VM) -> () ) throws -> UITableViewController {
    // Holiday Extravaganza TODO: SoErroneous
    guard let model = NSManagedObjectModel(named: "UserKit", inBundle: NSBundle(forClass: User.self)) else { fatalError("problems?") }
    let storeURL = session.localStoreDirectoryURL.URLByAppendingPathComponent("user.sqlite")
    
    let context = try NSManagedObjectContext(storeURL: storeURL, model: model)
    
    let frc = User.fetchedResults(nil, sortDescriptors: ["name".ascending], sectionNameKeypath: nil, inContext: context)
    let collection = try FetchedCollection(frc: frc, viewModelFactory: viewModelFactory)
    
    let remote = try User.getObserveeUsers(session)
    let fetchRequest = User.fetch(nil, sortDescriptors: ["name".ascending], inContext: context)
    let sync = User.syncSignalProducer(fetchRequest, inContext: context, fetchRemote: remote).map({ $0.map({ $0.obverveeID = session.user.id }) })
    
    return TableViewController(collection: collection, syncProducer: sync, didSelectItem: didSelectItem)
}