//
//  Alert+NetworkTests.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import ObserverAlertKit
import XCTest
import SoAutomated
import SoPersistent
import TooLegit
import DoNotShipThis
import Marshal
import Result

extension AlertTests {
    func testGetObserveeAlerts() {
        let session = Session.parentTest

        var response: [JSONObject]?
        stub(session, "observee-alerts") { expectation in
            response = try! Alert.getObserveeAlerts(session, observeeID: "16").first()?.value
            expectation.fulfill()
        }

        guard let alerts = response, alert = alerts.first where alerts.count == 2 else {
            XCTFail("unexpected response")
            return
        }

        XCTAssertEqual("14647296665340.32462932192720473", alert["id"] as? NSString, "id should be set")
    }

    func testGetAllAlerts() {
        let session = Session.parentTest

        var response: [JSONObject]?
        stub(session, "all-alerts") { expectation in
            try! Alert.getAlerts(session).startWithCompletedExpectation(expectation) { value in
                response = value
            }
        }

        guard let alerts = response, alert = alerts.first where alerts.count == 2 else {
            XCTFail("unexpected response")
            return
        }

        XCTAssertEqual("14647296665340.32462932192720473", alert["id"] as? NSString, "id should be set")
    }

    func testMarkAsRead() {
        let session = Session.parentTest
        let context = try! session.alertsManagedObjectContext()

        let alert = Alert.build(context)
        let json = Alert.validJSON
        try! alert.updateValues(json, inContext: context)

        var response: JSONObject?
        stub(session, "mark-alert-read") { expectation in
            try! alert.markAsRead(true, session: session).startWithCompletedExpectation(expectation) { value in
                response = value
            }
        }
        XCTAssertNotNil(response)
    }

    func testMarkDismissed() {
        let session = Session.parentTest
        let context = try! session.alertsManagedObjectContext()

        let alert = Alert.build(context)
        let json = Alert.validJSON
        try! alert.updateValues(json, inContext: context)

        var response: JSONObject?
        stub(session, "mark-alert-dismissed") { expectation in
            try! alert.markDismissed(true, session: session).startWithCompletedExpectation(expectation) { value in
                response = value
            }
        }
        XCTAssertNotNil(response)
    }
}

extension String: Fixture {
    public var name: String { return self }
    public var bundle: NSBundle { return NSBundle(forClass: AlertTests.self) }
}