//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
import SoSeedySwift
import EarlGrey
import WebKit
@testable import Core
@testable import Student

public class StudentUITest: XCTestCase {
    let shouldUseVCR = false
    override public func setUp() {
        super.setUp()
        VCR.shared.record = false
        if shouldUseVCR {
            self.loadCassette()
        }
        GREYCondition(name: "Waiting for app to startup", block: {
            var errorOrNil: NSError?
            EarlGrey.selectElement(with: grey_kindOfClass(WKWebView.self)).assert(grey_notNil(), error: &errorOrNil)
            let success = errorOrNil == nil
            return success
        }).wait(withTimeout: 5.0, pollInterval: 0.5)
    }

    override public func tearDown() {
        super.tearDown()
        if shouldUseVCR {
            self.recordCassette()
        }
    }

    func loadCassette() {
        let expectation = XCTestExpectation(description: "Load cassette")
        VCR.shared.loadCassette(testCase: self.name) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func recordCassette() {
        let expectation = XCTestExpectation(description: "Record cassette")
        VCR.shared.recordCassette(testCase: self.name) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func login(as user: Soseedy_CanvasUser) {
        Keychain.currentSession = KeychainEntry(token: user.token, baseURL: "https://\(user.domain)")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.environment.api = RecordableAPI()
        appDelegate.window?.rootViewController = appDelegate.createTabController()
        GREYCondition(name: "Waiting for dashboard to load", block: {
            var errorOrNil: NSError?
            EarlGrey.selectElement(with: grey_text("Courses"))
                .assert(grey_notNil(), error: &errorOrNil)
            let success = errorOrNil == nil
            print("Dashboard success \(success)")
            return success
        }).wait(withTimeout: 5.0, pollInterval: 0.5)
    }
}
