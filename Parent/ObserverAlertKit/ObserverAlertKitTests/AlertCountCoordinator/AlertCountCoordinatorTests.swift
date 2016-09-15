//
//  AlertCountCoordinatorTests.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 6/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
@testable import ObserverAlertKit
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
import AVFoundation

class AlertCountCoordinatorTests: XCTestCase {

    func testAlertCountCoordinator_unreadPredicate() {
        attempt {
            let session = Session.parentTest
            let predicate = Alert.unreadPredicate()

            let context = try session.alertsManagedObjectContext()
            let alertRead = Alert.build(context)
            alertRead.read = true

            let alertNotRead = Alert.build(context)
            alertNotRead.read = false

            let _ = AlertCountCoordinator(session: session, predicate: predicate) { count in
                XCTAssertEqual(1, count, "There should only be 1 not read alert counted")
            }
        }
    }

    func testAlertCountCoordinator_UndismissedPredicate() {
        attempt {
            let session = Session.parentTest
            let predicate = Alert.undismissedPredicate()

            let context = try session.alertsManagedObjectContext()
            let alertRead = Alert.build(context)
            alertRead.dismissed = true

            let alertNotRead = Alert.build(context)
            alertNotRead.dismissed = false

            let _ = AlertCountCoordinator(session: session, predicate: predicate) { count in
                XCTAssertEqual(1, count, "There should only be 1 not read alert counted")
            }
        }
    }


}