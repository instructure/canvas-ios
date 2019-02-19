//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import XCTest
import SoSeedySwift
import EarlGrey
import WebKit
@testable import Core
@testable import Student

public class StudentUITest: XCTestCase {
    let shouldUseVCR = true
    override public func setUp() {
        super.setUp()
        VCR.shared.record = true
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
            do {
                try VCR.shared.recordCassette(testCase: self.name)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func loadCassette() {
        do {
            let bundle = Bundle(for: type(of: self))
            guard let cassettePath = bundle.path(forResource: VCR.shared.stripTestCase(self.name), ofType: "json") else {
                return
            }

            let cassetteURL = URL(fileURLWithPath: cassettePath)
            let data = try Data(contentsOf: cassetteURL)
            try VCR.shared.loadCassette(cassetteFileContents: data)
        } catch {
            XCTFail(error.localizedDescription)
        }
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
            let success: Bool = errorOrNil == nil
            print("Dashboard success \(success)")
            return success
        }).wait(withTimeout: 5.0, pollInterval: 0.5)
    }
}
