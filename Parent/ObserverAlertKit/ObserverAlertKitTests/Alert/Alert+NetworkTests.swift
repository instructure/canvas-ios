//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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