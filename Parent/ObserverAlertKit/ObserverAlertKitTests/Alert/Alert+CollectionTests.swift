//
//  Alert+CollectionTests.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
@testable import ObserverAlertKit

class AlertCollectionsTests: XCTestCase {

    func testAlertCollection_TableViewControllerPrepare() {
        attempt {
            let session = Session.parentTest
            
            let collection = try Alert.collectionOfObserveeAlerts(session, observeeID: "16")
            let viewModelFactory = ViewModelFactory<Alert>.new { _ in UITableViewCell() }
            let refresher = try Alert.refresher(session, observeeID: "16")
            let tvc = Alert.TableViewController()

            tvc.prepare(collection, refresher: refresher, viewModelFactory: viewModelFactory)

            XCTAssertEqual(collection, tvc.collection)
            XCTAssertNotNil(tvc.dataSource)
            XCTAssertNotNil(tvc.refresher)
        }
    }

}
