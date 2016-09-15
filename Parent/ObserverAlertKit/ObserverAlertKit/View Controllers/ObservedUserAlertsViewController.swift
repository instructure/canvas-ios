//
//  ObservedUserAlertsViewController.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 2/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

public func observedUserAlertsViewController<VM: TableViewCellViewModel>(session: Session, viewModelFactory: AlertProtocol->VM, observeeID: Int64) throws -> UITableViewController {
    guard let model = NSManagedObjectModel(named: "ObserverAlertKit", inBundle: NSBundle(forClass: Alert.self)) else { fatalError("problems?") }
    let storeURL = session.localStoreDirectoryURL.URLByAppendingPathComponent("observeralerts.sqlite")

    let context = try NSManagedObjectContext(storeURL: storeURL, model: model)

    let frc = Alert.fetchedResults(nil, sortDescriptors: [], sectionNameKeypath: nil, inContext: context)
    let collection = try FetchedCollection(frc: frc, viewModelFactory: viewModelFactory)

    let remote = try Alert.getObserveeAlerts(session, observeeID: observeeID)
    let fetchRequest = Alert.fetch(nil, sortDescriptors: [], inContext: context)
    let sync = Alert.syncSignalProducer(fetchRequest, inContext: context, fetchRemote: remote)

    return TableViewController(collection: collection, syncProducer: sync, didSelectItem: { _ in })
}