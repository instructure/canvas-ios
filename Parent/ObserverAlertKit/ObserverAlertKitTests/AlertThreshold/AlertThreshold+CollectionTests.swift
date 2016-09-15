//
//  AlertThreshold+CollectionTests.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 6/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
@testable import ObserverAlertKit

class AlertThresholdCollectionsTests: XCTestCase {

    func testAlertCollection_TableViewControllerPrepare() {
        attempt {
            let session = Session.parentTest

            let collection = try AlertThreshold.collectionOfObserveeAlertThresholds(session, observeeID: "16")
            let viewModelFactory = ViewModelFactory<AlertThreshold>.new { _ in UITableViewCell() }
            let refresher = try AlertThreshold.refresher(session, observeeID: "16")
            let tvc = AlertThreshold.TableViewController()

            tvc.prepare(collection, refresher: refresher, viewModelFactory: viewModelFactory)

            XCTAssertEqual(collection, tvc.collection)
            XCTAssertNotNil(tvc.dataSource)
            XCTAssertNotNil(tvc.refresher)
        }
    }
    
}